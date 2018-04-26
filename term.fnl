(local font (love.graphics.newFont "assets/FSEX300.ttf" 16))
(local bg (love.graphics.newImage "assets/term.bmp"))

(var text (love.filesystem.read "text/first"))
(var offset 0)

{:draw (fn []
         (love.graphics.draw bg 0 0)
         (love.graphics.print text 12 (+ 12 (* offset 18))))
 :update (fn [])
 :activate (fn [which]
             (love.graphics.setFont font)
             (set text (love.filesystem.read (.. "text/" which))))
 :keypressed (fn [key set-mode]
               (if (= key "up")
                   (set offset (math.max 0 (- offset 1)))
                   (= key "down")
                   (set offset (math.min 16 (+ offset 1)))
                   (or (= key "return") (= key "escape"))
                   (set-mode :play)))}
