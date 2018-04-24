(local tiled (require "lib.tiled"))
(local bump (require "lib.bump"))
(local lume (require "lib.lume"))
(local draw (require "draw"))
(local laser (require "laser"))
(local sensor (require "sensor"))

(local map (tiled "map.lua" ["bump"]))
(local world (bump.newWorld))

(local state {:tx 0 :ty -1024 ; <- viewport translation
              :rovers [{:theta 0 :docked true :type :rover}
                       {:theta 0 :docked false :type :rover}
                       {:theta 0 :docked false :type :rover}
                       {:theta 0 :docked true :type :rover}]
              :probe {:theta 0 :type :probe :rovers []}})

(: map :bump_init world)
;; (let [radius 5]
;;   (: world :add (. state.rovers 1) 100 1200 (* 2 radius) (* 2 radius))
;;   (: world :add (. state.rovers 2) 120 1200 (* 2 radius) (* 2 radius))
;;   (: world :add (. state.rovers 3) 120 1220 (* 2 radius) (* 2 radius))
;;   (: world :add (. state.rovers 4) 100 1220 (* 2 radius) (* 2 radius)))
(: world :add state.probe 105 1205 20 20)

(local turn-speed math.pi)
(local rover-move-speed 35)
(local probe-move-speed 20)

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
  (let [(x y w h) (: world :getRect state.selected)
        new-x (+ x (* (math.cos rover.theta) rover-move-speed dt))
        new-y (+ y (* (math.sin rover.theta) rover-move-speed dt))]
    (values new-x new-y)))

(defn move-rover [dt]
  (when (love.keyboard.isDown "left")
    (set state.selected.theta (- state.selected.theta (* dt turn-speed))))
  (when (love.keyboard.isDown "right")
    (set state.selected.theta (+ state.selected.theta (* dt turn-speed))))
  (when (love.keyboard.isDown "up")
    (let [(new-x new-y) (calculate-new-rover-position state.selected dt)
          (actual-x actual-y cols len) (: world :move
                                          state.selected new-x new-y)]
      (when (> len 0)
        nil))))

(defn move-probe [dt]
  (let [left? (if (love.keyboard.isDown "left") 1 0)
        right? (if (love.keyboard.isDown "right") 1 0)
        up? (if (love.keyboard.isDown "up") 1 0)
        down? (if (love.keyboard.isDown "down") 1 0)]
    (when (> (+ left? right? up? down?) 0)
      (let [(x y w h) (: world :getRect state.selected)
            new-x (+ x
                     (- (* left? probe-move-speed dt))
                     (* right? probe-move-speed dt))
            new-y (+ y
                     (- (* up? probe-move-speed dt))
                     (* down? probe-move-speed dt))
            (actual-x actual-y cols len) (: world :move
                                            state.selected new-x new-y)]
        (when (> len 0)
          nil)))))

(defn update [dt set-mode]
  (sensor.update state map dt)
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
    (move-rover dt))
  (when (= :probe state.selected.type)
    (move-probe dt))
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
      (set state.probe.theta (+ state.probe.theta (* dt turn-speed))))))

(local offsets [[-10 -10] [20 -10] [20 20] [-10 20]])

(defn deploy [n]
  (table.insert state.probe.rovers n)
  (let [radius 5
        [ox oy] (. offsets n)
        (px py) (: world :getRect state.probe)]
    (: world :add (. state.rovers n) (+ px ox) (+ py oy)
       (* 2 radius) (* 2 radius))))

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
               "`" select})

(defn keypressed [key set-mode]
  (let [f (. keymap key)]
    (if (= "escape" key)
        (set-mode :pause)
        (= (type f) "function")
        (f))))

{:draw (partial draw.draw map world state)
 :update update
 :keypressed keypressed}
