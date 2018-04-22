(local tiled (require "lib.tiled"))
(local bump (require "lib.bump"))
(local lume (require "lib.lume"))
(local draw (require "draw"))
(local laser (require "laser"))

(local map (tiled "map.lua" ["bump"]))
(local world (bump.newWorld))

(local state {:tx 0 :ty -1024 ; <- viewport translation
              :rovers [{:theta 0 :docked true :type :rover}
                       {:theta 0 :docked false :type :rover}
                       {:theta 0 :docked false :type :rover}
                       {:theta 0 :docked true :type :rover}]
              :probe {:theta 0 :type :probe}})

(: map :bump_init world)
(let [radius 5]
  (: world :add (. state.rovers 1) 100 1200 (* 2 radius) (* 2 radius))
  (: world :add (. state.rovers 2) 120 1200 (* 2 radius) (* 2 radius))
  (: world :add (. state.rovers 3) 120 1220 (* 2 radius) (* 2 radius))
  (: world :add (. state.rovers 4) 100 1220 (* 2 radius) (* 2 radius)))
(: world :add state.probe 105 1205 20 20)

(local turn-speed math.pi)

(set state.selected (. state.rovers 1))

(let [layer (: map :addCustomLayer "player")]
  (set layer.sprites [(unpack state.rovers)])
  (tset layer.sprites 0 state.probe)
  (set layer.draw (partial draw.draw-player world state)))

;; so we can access this thru the repl
(global st state)

(local dirs {:home [0 -1] :end [0 1] :delete [-1 0] :pagedown [1 0]})

(defn move-rover [dt]
  (when (love.keyboard.isDown "left")
    (set state.selected.theta (- state.selected.theta (* dt turn-speed))))
  (when (love.keyboard.isDown "right")
    (set state.selected.theta (+ state.selected.theta (* dt turn-speed))))
  (when (love.keyboard.isDown "up")
    (let [x state.selected.x ;; todo: calculate trig
          y state.selected.y]
      (: world :move state.selected x y))))

(defn update [dt set-mode]
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
  ;; we'll move all the controls to their own module soon
  (set state.laser (and (love.keyboard.isDown "space")
                        (let [(x y w h) (: world :getRect state.probe)]
                          (laser.fire (+ x (/ w 2))
                                      (+ y (/ h 2))
                                      state.probe.theta world
                                      [] state.probe 64))))
  (let [turn-speed (if (love.keyboard.isDown "lshift" "rshift")
                       (* turn-speed 0.3)
                       turn-speed)]
    (when (love.keyboard.isDown ",")
      (set state.probe.theta (- state.probe.theta (* dt turn-speed))))
    (when (love.keyboard.isDown ".")
      (set state.probe.theta (+ state.probe.theta (* dt turn-speed))))))

(defn select [n]
  (set state.selected (if (= n 0)
                          state.probe
                          (. state.rovers n))))

(local keymap {:1 (partial select 1)
               :2 (partial select 2)
               :3 (partial select 3)
               :4 (partial select 4)
               :0 (partial select 0)
               :5 (partial select 0)
               "`" (partial select 0)})

(defn keypressed [key set-mode]
  (let [f (. keymap key)]
    (if (= "escape" key)
        (set-mode :pause)
        (= (type f) "function")
        (f))))

{:draw (partial draw.draw map world state)
 :update update
 :keypressed keypressed}
