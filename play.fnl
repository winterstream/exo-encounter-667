(local lume (require :lib.lume))
(local draw (require :draw))
(local hud (require :hud))
(local laser (require :laser))
(local sensor (require :sensor))
(local sound (require :sound))
(local autopilot (require :autopilot))

(local state (require :state))

(local turn-speed 1)
(local rover-move-speed 82)
(local probe-move-speed 64)

(local map state.map)
(local world state.world)

(set state.selected state.probe)

;; set up custom layers which aren't preloaded in the map
(let [layer (map:addCustomLayer :player 8)]
  (set layer.sprites [(unpack state.rovers)])
  (tset layer.sprites 0 state.probe)
  (set layer.draw (partial draw.player world state)))

;; layers where we change the drawing of the sprites based on gameplay can't
;; be drawn by tiled; we have to write our own draw.
(set map.layers.sensors.draw draw.sensors)
(set map.layers.doors.draw draw.doors)

(fn calculate-new-rover-position [rover dt]
  (let [(x y) (world:getRect rover)
        new-x (+ x (* (math.cos rover.theta) rover-move-speed dt))
        new-y (+ y (* (math.sin rover.theta) rover-move-speed dt))]
    (values new-x new-y)))

(fn within? [item box margin]
  (let [(x y width height) (world:getRect item)]
    (and (< (- box.x margin) x (+ x width) (+ box.x box.width margin))
         (< (- box.y margin) y (+ y height) (+ box.y box.height margin)))))

(fn terminal-check [cols unit set-mode]
  (set state.selected.in-term? false)
  (each [_ col (ipairs cols)]
    (when (and col.other.properties col.other.properties.terminal
               (within? col.item col.other 0))
      (set unit.in-term? true)
      (when (not unit.in-term-last-tick?)
        (set-mode :term col.other.properties.terminal)))))

(fn collide-filter [_item other]
  (if (or (love.keyboard.isDown :backspace) ; noclip
          (and other.properties other.properties.terminal))
      :cross
      :slide))

(fn rover-forward [set-mode r delta]
  (let [(new-x new-y) (calculate-new-rover-position r delta)
        (_ _ cols) (world:move r new-x new-y collide-filter)]
    (terminal-check cols r set-mode)))

(fn move-rover [dt set-mode]
  (when (love.keyboard.isDown :left)
    (set state.selected.theta (- state.selected.theta (* 2 dt turn-speed))))
  (when (love.keyboard.isDown :right)
    (set state.selected.theta (+ state.selected.theta (* 2 dt turn-speed))))
  (when (or (love.keyboard.isDown :up) (love.keyboard.isDown :down))
    (rover-forward set-mode state.selected
                   (if (love.keyboard.isDown :up) dt (- dt)))))

(fn move-probe [dt set-mode]
  (let [left? (if (love.keyboard.isDown :left) 1 0)
        right? (if (love.keyboard.isDown :right) 1 0)
        up? (if (love.keyboard.isDown :up) 1 0)
        down? (if (love.keyboard.isDown :down) 1 0)]
    (set state.probe.stuck?
         (and (> (+ left? right? up? down?) 0) (not state.probe.mobile?)))
    (when (and (> (+ left? right? up? down?) 0) state.probe.mobile?)
      (let [speed (if (love.keyboard.isDown "=") 164 probe-move-speed)
            (x y) (world:getRect state.selected)
            new-x (+ x (- (* left? speed dt)) (* right? speed dt))
            new-y (+ y (- (* up? speed dt)) (* down? speed dt))
            (_ _ cols) (world:move state.selected new-x new-y collide-filter)]
        (terminal-check cols state.selected set-mode)))))

;; there is surely a smarter way to write this but I'm tired and it's late
(fn scroll [state dt x y]
  (let [dist (lume.distance x y (+ state.tx 180) (+ state.ty 112))
        ;; scroll faster when the selected unit is offscreen, unless intro
        delta (if (and (> dist 200) state.intro-complete?)
                  (* dt probe-move-speed (* (math.sqrt (* dist 100)) 0.02))
                  (* dt probe-move-speed))]
    (when (< (+ state.tx 260) x)
      (set state.tx (math.min (+ state.tx delta) 1559)))
    (when (< x (+ state.tx 80))
      (set state.tx (math.max (- state.tx delta) 0)))
    (when (< (+ state.ty 165) y)
      (set state.ty (math.min (+ state.ty delta) 1054)))
    (when (< y (+ state.ty 100))
      (set state.ty (math.max (- state.ty delta) 0)))))

(fn update [dt set-mode]
  (set state.probe.stuck? false)
  (pcall (fn [] (hud.update state world map dt)))
  (map:update dt)
  (scroll state dt (world:getRect state.selected))
  ;; controls
  (when (not state.selected.immobilized?)
    (let [dt2 (if (love.keyboard.isDown :lshift :rshift) (* dt 0.2) dt)]
      (when (= :rover state.selected.type)
        (move-rover dt2 set-mode))
      (when (= :probe state.selected.type)
        (move-probe dt2 set-mode))
      (when (love.keyboard.isDown "," :w)
        (set state.probe.theta (- state.probe.theta (* dt2 turn-speed))))
      (when (love.keyboard.isDown "." :v)
        (set state.probe.theta (+ state.probe.theta (* dt2 turn-speed))))))
  (sensor.update state map world dt)
  (autopilot.update state world dt (partial rover-forward set-mode))
  (if (love.keyboard.isDown :space :lctrl :rctrl :capslock)
      (sound.play :laser)
      (sound.stop :laser))
  (set state.laser (and (love.keyboard.isDown :space :lctrl :rctrl :capslock)
                        (let [(x y w h) (world:getRect state.probe)]
                          (laser.fire (+ x (/ w 2)) (+ y (/ h 2) -6)
                                      state.probe.theta state world map []
                                      [state.probe] 64))))
  (when (= :win state.laser)
    (set-mode :win))
  (set state.selected.in-term-last-tick? state.selected.in-term?))

;; can't move unless 3 or 4 rovers are docked
(fn enough-docked? []
  (< 2 (length (lume.filter state.rovers :docked?))))

;; TODO: these are bad
(local offsets [[-10 -10] [20 -10] [20 20] [-10 20]])

(fn deploy [n]
  (tset (. state.rovers n) :docked? false)
  (set state.probe.mobile? (enough-docked?))
  (let [[ox oy] (. offsets n)
        (px py) (world:getRect state.probe)]
    (world:add (. state.rovers n) (+ px ox) (+ py oy) 10 10)))

(fn dock []
  (let [(x y w h) (world:getRect state.probe)]
    (when (and (= state.selected.type :rover)
               (within? state.selected {: x : y :width w :height h} 12))
      (set state.selected.docked? true)
      (set state.probe.mobile? (enough-docked?))
      (world:remove state.selected)
      (set state.selected state.probe))))

(fn select [n]
  (when n (autopilot.disable))
  (set state.selected (if n
                          (. state.rovers n)
                          state.probe))
  (when (and n (not (world:hasItem (. state.rovers n))))
    (deploy n)))

(local keymap
       {:1 (partial select 1)
        :2 (partial select 2)
        :3 (partial select 3)
        :4 (partial select 4)
        :0 select
        :5 select
        "`" select
        :return dock
        :backspace (fn [] (autopilot.enable) (select nil))})

(fn keypressed [key set-mode]
  (let [f (. keymap key)]
    (if (or (= :escape key) (= :f1 key)) (set-mode :pause)
        (= (type f) :function) (f))))

{:draw (partial draw.draw map world state) : update : keypressed}
