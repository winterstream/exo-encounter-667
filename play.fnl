(local tiled (require "lib.tiled"))
(local bump (require "lib.bump"))
(local lume (require "lib.lume"))
(local draw (require "draw"))
(local hud (require "hud"))
(local laser (require "laser"))
(local sensor (require "sensor"))

(local map (tiled "map.lua" ["bump"]))
(local world (bump.newWorld))

(local state {:tx 0 :ty -1024 ; <- viewport translation
              :rovers [{:theta 0 :docked? true :type :rover}
                       {:theta 0 :docked? true :type :rover}
                       {:theta 0 :docked? true :type :rover}
                       {:theta 0 :docked? true :type :rover}]
              :probe {:theta 0 :type :probe :rovers []}
              :messages []})

(: map :bump_init world)
(: world :add state.probe 105 1205 30 24)

(local turn-speed math.pi)
(local rover-move-speed 42)
(local probe-move-speed 24)

(set state.selected state.probe)

(let [layer (: map :addCustomLayer "player")]
  (set layer.sprites [(unpack state.rovers)])
  (tset layer.sprites 0 state.probe)
  (set layer.draw (partial draw.draw-player world state)))

(sensor.init state map)
(set map.layers.sensors.draw draw.draw-sensors)
(set map.layers.doors.draw draw.draw-doors)

;; so we can access these thru the repl
(global st state)
(global m map)
(global w world)

(local dirs {:home [0 -1] :end [0 1] :delete [-1 0] :pagedown [1 0]})

(defn calculate-new-rover-position [rover dt]
  (let [(x y) (: world :getRect state.selected)
        new-x (+ x (* (math.cos rover.theta) rover-move-speed dt))
        new-y (+ y (* (math.sin rover.theta) rover-move-speed dt))]
    (values new-x new-y)))

(defn within? [item box]
  (let [(x y width height) (: world :getRect item)
        margin 3]
    (and (< (+ box.x margin) x (+ x width) (- (+ box.x box.width) margin))
         (< (+ box.y margin) y (+ y height) (- (+ box.y box.height) margin)))))

(defn terminal-check [cols unit set-mode]
  (each [_ col (ipairs cols)]
    (when (and col.other.properties col.other.properties.terminal
               (within? col.item col.other))
      (set unit.in-term? true)
      (when (not unit.in-term-last-tick?)
        (set-mode :term col.other.properties.terminal)))))

(defn collide-filter [_item other]
  (if (and other.properties other.properties.terminal)
      :cross
      :slide))

(defn move-rover [dt set-mode]
  (when (love.keyboard.isDown "left")
    (set state.selected.theta (- state.selected.theta (* dt turn-speed))))
  (when (love.keyboard.isDown "right")
    (set state.selected.theta (+ state.selected.theta (* dt turn-speed))))
  (when (love.keyboard.isDown "up")
    (set state.selected.in-term? false)
    (let [(new-x new-y) (calculate-new-rover-position state.selected dt)
          (_ _ cols) (: world :move state.selected new-x new-y collide-filter)]
      (terminal-check cols state.selected set-mode))))

(defn move-probe [dt set-mode]
  (let [left? (if (love.keyboard.isDown "left") 1 0)
        right? (if (love.keyboard.isDown "right") 1 0)
        up? (if (love.keyboard.isDown "up") 1 0)
        down? (if (love.keyboard.isDown "down") 1 0)]
    (when (> (+ left? right? up? down?) 0)
      (let [(x y) (: world :getRect state.selected)
            new-x (+ x
                     (- (* left? probe-move-speed dt))
                     (* right? probe-move-speed dt))
            new-y (+ y
                     (- (* up? probe-move-speed dt))
                     (* down? probe-move-speed dt))
            (_ _ cols) (: world :move state.selected new-x new-y collide-filter)]
        (terminal-check cols state.selected set-mode)))))

(defn update [dt set-mode]
  (sensor.update state map dt)
  (hud.update state dt)
  (: map :update dt)
  ;; placeholder: for now, you scroll manually
  (each [key delta (pairs dirs)]
    (when (love.keyboard.isDown key)
      (let [[dx dy] delta scroll-speed 64]
        (set state.tx (lume.clamp (- state.tx (* (* dx scroll-speed) dt))
                                  -1280 0))
        (set state.ty (lume.clamp (- state.ty (* (* dy scroll-speed) dt))
                                  -1024 0)))))
  (when (= :rover state.selected.type)
    (move-rover dt set-mode))
  (when (= :probe state.selected.type)
    (move-probe dt set-mode))
  (set state.laser (and (love.keyboard.isDown "space")
                        (let [(x y w h) (: world :getRect state.probe)]
                          (laser.fire (+ x (/ w 2))
                                      (+ y (/ h 2))
                                      state.probe.theta world map
                                      [] [state.probe] 64))))
  (let [turn-speed (if (love.keyboard.isDown "lshift" "rshift")
                       (* turn-speed 0.3)
                       turn-speed)]
    (when (love.keyboard.isDown ",")
      (set state.probe.theta (- state.probe.theta (* dt turn-speed))))
    (when (love.keyboard.isDown ".")
      (set state.probe.theta (+ state.probe.theta (* dt turn-speed)))))
  (set state.selected.in-term-last-tick? state.selected.in-term?))

(local offsets [[-10 -10] [20 -10] [20 20] [-10 20]])

(defn deploy [n]
  (tset (. state.rovers n) :docked? false)
  (let [diameter 10
        [ox oy] (. offsets n)
        (px py) (: world :getRect state.probe)]
    (: world :add (. state.rovers n) (+ px ox) (+ py oy) diameter diameter)))

(defn xywh [x y w h] {:x x :y y :width w :height h})

(defn dock []
  (when (and (= state.selected.type :rover)
             (within? state.selected (xywh (: world :getRect state.probe))))
    (set state.selected.docked? true)
    (: world :remove state.selected)))

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
               :return dock})

(defn keypressed [key set-mode]
  (let [f (. keymap key)]
    (if (= "escape" key)
        (set-mode :pause)
        (= (type f) "function")
        (f))))

{:draw (partial draw.draw map world state)
 :update update
 :keypressed keypressed}
