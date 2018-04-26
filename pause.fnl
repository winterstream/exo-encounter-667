(local font (love.graphics.newFont "assets/FSEX300.ttf" 16))
(local help (love.filesystem.read "text/help"))

(let [intro (require :intro)]
  {:draw (partial intro.draw help)
   :update (fn [])
   :keypressed (fn [key set-mode]
                 (if (= key "q")
                     (love.event.quit)
                     (do (set-mode :play)
                         (love.graphics.setFont font))))})
