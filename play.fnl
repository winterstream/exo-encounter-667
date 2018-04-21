(local tiled (require "lib.tiled"))
(local bump (require "lib.bump"))
(local lume (require "lib.lume"))
(local draw (require "draw"))

(local map (tiled "map.lua" ["bump"]))
(local world (bump.newWorld))
(local rover-radius 5)
(local probe-width 20)

(local state {:tx 0 :ty -1024 ; <- viewport translation
              :rovers [{:x 100 :y 1200 :r 0 :docked true :type :rover}
                       {:x 120 :y 1200 :r 0 :docked false :type :rover}
                       {:x 120 :y 1220 :r 0 :docked false :type :rover}
                       {:x 100 :y 1220 :r 0 :docked true :type :rover}]})

(: map :bump_init world)
(each [_ rover (pairs state.rovers)]
  (: world :add rover rover.x rover.y rover-radius rover-radius))

(local turn-speed math.pi)

(set state.selected (. state.rovers 1))

(let [layer (: map :addCustomLayer "player")]
  (set layer.sprites state.rovers)
  (set layer.draw (partial draw.draw-player state)))

;; so we can access this thru the repl
(global st state)

(local dirs {:home [0 -1] :end [0 1] :delete [-1 0] :pagedown [1 0]})

(defn move-rover []
  (when (love.keyboard.isDown "left")
    (set state.selected.r (- state.selected.r (* dt turn-speed))))
  (when (love.keyboard.isDown "right")
    (set state.selected.r (+ state.selected.r (* dt turn-speed))))
  (when (love.keyboard.isDown "up")
    (let [x selected.x ;; todo: calculate trig
          y selected.y]
      (: world :move selected x y))))

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
  (when (= :rover selected.type)
    (move-rover)))

(defn select [n] (set state.selected (. state.rovers n)))

(local keymap {:1 (partial select 1)
               :2 (partial select 2)
               :3 (partial select 3)
               :4 (partial select 4)})

(defn keypressed [key set-mode]
  (let [f (. keymap key)]
    (if (= "escape" key)
        (set-mode :pause)
        (= (type f) "function")
        (f))))

{:draw (partial draw.draw map state)
 :update update
 :keypressed keypressed}
