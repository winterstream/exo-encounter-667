(local beholder (require :lib.beholder))
(local lume (require :lib.lume))
(local draw (require :draw))
(local hud (require :hud))
(local laser (require :laser))
(local sensor (require :sensor))
(local sound (require :sound))

(local const (require :const))
(local state (require :state))

(local turn-speed const.turn-speed)

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

(fn within? [item box margin]
  (let [(x y width height) (world:getRect item)]
    (and (< (- box.x margin) x (+ x width) (+ box.x box.width margin))
         (< (- box.y margin) y (+ y height) (+ box.y box.height margin)))))

(fn update [dt set-mode]
  (pcall (fn [] (hud.update state world map dt)))
  (map:update dt)
  ;; controls
  (when (not state.selected.immobilized?)
    (let [dt2 (if (love.keyboard.isDown :lshift :rshift) (* dt 0.2) dt)]
      (when (love.keyboard.isDown "," :w)
        (set state.probe.theta (- state.probe.theta (* dt2 turn-speed))))
      (when (love.keyboard.isDown "." :v)
        (set state.probe.theta (+ state.probe.theta (* dt2 turn-speed))))))
  (sensor.update state map world dt)
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
  (when n (beholder.trigger :enable-autopilot false))
  (set state.selected (if n
                          (. state.rovers n)
                          state.probe))
  (when (and n (not (world:hasItem (. state.rovers n))))
    (deploy n)))

(local keymap {:1 (partial select 1)
               :2 (partial select 2)
               :3 (partial select 3)
               :4 (partial select 4)
               :0 select
               :5 select
               "`" select
               :return dock})

(fn keypressed [key set-mode]
  (let [f (. keymap key)]
    (if (or (= :escape key) (= :f1 key)) (set-mode :pause)
        (= (type f) :function) (f))))

{:draw (partial draw.draw map world state) : update : keypressed}
