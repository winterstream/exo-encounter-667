(local tiled (require "lib.tiled"))
(local bump (require "lib.bump"))
(local lume (require "lib.lume"))
(local draw (require "draw"))
(local laser (require "laser"))

(local map (tiled "map.lua" ["bump"]))
(local world (bump.newWorld))
(local rover-radius 5)
(local probe-width 20)

(local state {:tx 0 :ty -1024 ; <- viewport translation
              :rovers [{:x 100 :y 1200 :theta 0 :docked true
                        :type :rover :radius rover-radius
                        :width (* rover-radius 2) :height (* rover-radius 2)}
                       {:x 120 :y 1200 :theta 0 :docked false :type :rover
                        :radius rover-radius
                        :width (* rover-radius 2) :height (* rover-radius 2)}
                       {:x 120 :y 1220 :theta 0 :docked false :type :rover
                        :radius rover-radius
                        :width (* rover-radius 2) :height (* rover-radius 2)}
                       {:x 100 :y 1220 :theta 0 :docked true :type :rover
                        :radius rover-radius
                        :width (* rover-radius 2) :height (* rover-radius 2)}]
              :probe {:x 105 :y 1205 :width 20 :height 20
                      :theta 0 :type :probe}})

(: map :bump_init world)
(each [_ rover (pairs state.rovers)]
  (: world :add rover rover.x rover.y (* 2 rover.radius) (* 2 rover.radius)))
(: world :add state.probe state.probe.x state.probe.y
   state.probe.width state.probe.height)

(local turn-speed math.pi)

(set state.selected (. state.rovers 1))

(let [layer (: map :addCustomLayer "player")]
  (set layer.sprites [(unpack state.rovers)])
  (tset layer.sprites 0 state.probe)
  (set layer.draw (partial draw.draw-player state)))

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
  (set state.laser (and (love.keyboard.isDown "space")
                        (= state.selected.type :probe)
                        (let [[x y w h] (: world :getRect state.probe)]
                          (laser.fire (+ x (/ w 2))
                                      (+ y (/ h 2))
                                      state.probe.theta world [])))))

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

{:draw (partial draw.draw map state)
 :update update
 :keypressed keypressed}
