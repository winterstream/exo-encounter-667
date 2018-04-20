(local tiled (require "lib.tiled"))
(local bump (require "lib.bump"))

(local map (tiled "map.lua" ["bump"]))
(local world (bump.newWorld))
(local state {:tx 0 :ty (- (* 50 20))})

;; so we can access this thru the repl
(global st state)

(local dirs {:up [0 -1] :down [0 1] :left [-1 0] :right [1 0]})
(local speed 64)

(defn update [dt set-mode]
  ;; placeholder: for now, the arrows allow scrolling
  (each [key delta (pairs dirs)]
    (when (love.keyboard.isDown key)
      (let [[dx dy] delta]
        (set state.tx (- state.tx (* (* dx speed) dt)))
        (set state.ty (- state.ty (* (* dy speed) dt)))))))

(local keymap {})

(defn keypressed [key set-mode]
  (let [f (. keymap key)]
    (if (= "escape" key)
        (set-mode :pause)
        (= (type f) "function")
        (f))))

{:draw (partial (require :draw) map state)
 :update update
 :keypressed keypressed}
