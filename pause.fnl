(let [intro (require :intro)]
  {:draw (partial intro.draw "press any key")
   :update (fn [])
   :keypressed (fn [key set-mode]
                 (if (= key "q")
                     (love.event.quit)
                     (set-mode :play)))})
