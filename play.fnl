(local tiled (require "lib.tiled"))
(local bump (require "lib.bump"))
(local lume (require "lib.lume"))
(local draw (require "draw"))
(local hud (require "hud"))
(local laser (require "laser"))
(local sensor (require "sensor"))
(local lint (require "lint"))

(local map (lint (tiled "map.lua" ["bump"])))
(local world (bump.newWorld))

(local state {:tx 200 :ty (if (os.getenv "QUICK") 1024 500)
              :rovers [{:theta 0 :docked? true :type :rover}
                       {:theta 3 :docked? false :type :rover}
                       {:theta 2 :docked? false :type :rover}
                       {:theta 0 :docked? true :type :rover}]
              :probe {:theta 0 :type :probe :rovers []}
              :flags {}
              :messages []
              :echo (fn [s msg] (table.insert s.messages 1 msg))})

(: map :bump_init world)
(: world :add state.probe 105 1205 30 24)
(: world :add (. state.rovers 2) 165 1200 10 10) ; start undocked
(: world :add (. state.rovers 3) 145 1212 10 10)

(local turn-speed math.pi)
(local rover-move-speed 72)
(local probe-move-speed 64)

(set state.selected state.probe)

(let [layer (: map :addCustomLayer "player" 8)]
  (set layer.sprites [(unpack state.rovers)])
  (tset layer.sprites 0 state.probe)
  (set layer.draw (partial draw.draw-player world state)))

;; layers where we change the drawing of the sprites based on gameplay can't
;; be drawn by tiled; we have to write our own draw.
(set map.layers.sensors.draw draw.draw-sensors)
(set map.layers.doors.draw draw.draw-doors)

;; so we can access these thru the repl
(global s state)
(global m map)
(global w world)

(defn calculate-new-rover-position [rover dt]
  (let [(x y) (: world :getRect state.selected)
        new-x (+ x (* (math.cos rover.theta) rover-move-speed dt))
        new-y (+ y (* (math.sin rover.theta) rover-move-speed dt))]
    (values new-x new-y)))

(defn within? [item box margin]
  (let [(x y width height) (: world :getRect item)]
    (and (< (- box.x margin) x (+ x width) (+ (+ box.x box.width) margin))
         (< (- box.y margin) y (+ y height) (+ (+ box.y box.height) margin)))))

(defn terminal-check [cols unit set-mode]
  (set state.selected.in-term? false)
  (each [_ col (ipairs cols)]
    (when (and col.other.properties col.other.properties.terminal
               (within? col.item col.other 0))
      (set unit.in-term? true)
      (when (not unit.in-term-last-tick?)
        (set-mode :term col.other.properties.terminal)))))

(defn collide-filter [_item other]
  (if (or (love.keyboard.isDown "backspace") ; noclip
          (and other.properties other.properties.terminal))
      :cross
      :slide))

(defn move-rover [dt set-mode]
  (when (love.keyboard.isDown "left")
    (set state.selected.theta (- state.selected.theta (* dt turn-speed))))
  (when (love.keyboard.isDown "right")
    (set state.selected.theta (+ state.selected.theta (* dt turn-speed))))
  (when (love.keyboard.isDown "up")
    (let [(new-x new-y) (calculate-new-rover-position state.selected dt)
          (_ _ cols) (: world :move state.selected new-x new-y collide-filter)]
      (terminal-check cols state.selected set-mode))))

(defn move-probe [dt set-mode]
  (let [left? (if (love.keyboard.isDown "left") 1 0)
        right? (if (love.keyboard.isDown "right") 1 0)
        up? (if (love.keyboard.isDown "up") 1 0)
        down? (if (love.keyboard.isDown "down") 1 0)]
    (set state.probe.stuck? (and (> (+ left? right? up? down?) 0)
                                 (not state.probe.mobile?)))
    (when (and (> (+ left? right? up? down?) 0) state.probe.mobile?)
      (let [speed (if (love.keyboard.isDown "rctrl") 164 probe-move-speed)
            (x y) (: world :getRect state.selected)
            new-x (+ x
                     (- (* left? speed dt))
                     (* right? speed dt))
            new-y (+ y
                     (- (* up? speed dt))
                     (* down? speed dt))
            (_ _ cols) (: world :move state.selected new-x new-y collide-filter)]
        (terminal-check cols state.selected set-mode)))))

;; there is surely a smarter way to write this but I'm tired and it's late
(defn scroll [state dt x y]
  ;; TODO: scroll faster when your selected unit is offscreen
  (let [delta (if (love.keyboard.isDown "rctrl")
                  (* dt 256)
                  (* dt 64))]
    (when (< (+ state.tx 300) x 1860)
      (set state.tx (+ state.tx delta)))
    (when (< x (+ state.tx 60))
      (set state.tx (math.max (- state.tx delta) 0)))
    (when (< (+ state.ty 165) y 1220)
      (set state.ty (math.min (+ state.ty delta) 1215)))
    (when (< y (+ state.ty 60))
      (set state.ty (math.max (- state.ty delta) 0)))))

(defn update [dt set-mode]
  (set state.probe.stuck? false)
  (let [(ok err) (pcall (fn [] (hud.update state world map dt)))]
    (when (not ok) (print err)))
  (: map :update dt)
  (scroll state dt (: world :getRect state.selected))
  ;; controls
  (let [dt2 (if (love.keyboard.isDown "lshift" "rshift") (* dt 0.5) dt)]
    (when (= :rover state.selected.type)
      (move-rover dt2 set-mode))
    (when (= :probe state.selected.type)
      (move-probe dt2 set-mode))
    (when (love.keyboard.isDown "," "w")
      (set state.probe.theta (- state.probe.theta (* dt2 turn-speed))))
    (when (love.keyboard.isDown "." "v")
      (set state.probe.theta (+ state.probe.theta (* dt2 turn-speed)))))
  (sensor.update state map world dt)
  (set state.laser (and (love.keyboard.isDown "space")
                        (let [(x y w h) (: world :getRect state.probe)]
                          (laser.fire (+ x (/ w 2))
                                      (+ y (/ h 2) -6)
                                      state.probe.theta world map
                                      [] [state.probe] 64))))
  (when (= :win state.laser)
    (set-mode :win))
  (set state.selected.in-term-last-tick? state.selected.in-term?))

;; can't move unless 3 or 4 rovers are docked
(defn enough-docked? [] (< 2 (# (lume.filter state.rovers :docked?))))

(local offsets [[-10 -10] [20 -10] [20 20] [-10 20]])

(defn deploy [n]
  (tset (. state.rovers n) :docked? false)
  (set state.probe.mobile? (enough-docked?))
  (let [diameter 10
        [ox oy] (. offsets n)
        (px py) (: world :getRect state.probe)]
    (: world :add (. state.rovers n) (+ px ox) (+ py oy) diameter diameter)))

(defn dock []
  (let [(x y w h) (: world :getRect state.probe)]
    (when (and (= state.selected.type :rover)
               (within? state.selected {:x x :y y :width w :height h} 12))
      (set state.selected.docked? true)
      (set state.probe.mobile? (enough-docked?))
      (: world :remove state.selected)
      (set state.selected state.probe))))

(defn select [n]
  (set state.selected (if n
                          (. state.rovers n)
                          state.probe))
  (when (and n (not (: world :hasItem (. state.rovers n))))
    (deploy n)))

(local keymap {:1 (partial select 1)
               :2 (partial select 2)
               :3 (partial select 3)
               :4 (partial select 4)
               :0 select
               :5 select
               "`" select
               :return dock
               :tab (fn [] (set state.no-hud (not state.no-hud)))})

(defn keypressed [key set-mode]
  (let [f (. keymap key)]
    (if (= "escape" key)
        (set-mode :pause)
        (= (type f) "function")
        (f))))

{:draw (partial draw.draw map world state)
 :update update
 :keypressed keypressed}
