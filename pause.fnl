(local help (love.filesystem.read :text/help))

(let [intro (require :intro)]
  {:draw (partial intro.draw help)
   :keypressed (fn [key set-mode]
                 (if (= key :q)
                     (love.event.quit)
                     (set-mode :play)))})
