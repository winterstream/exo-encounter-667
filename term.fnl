(local font (love.graphics.newFont "assets/FSEX300.ttf" 16))
(local bg (love.graphics.newImage "assets/term.bmp"))

(var offset 0)
(var which :first)

{:draw (fn []
         (love.graphics.draw bg 0 0)
         (let [txt (love.filesystem.read (.. "text/" which))]
           (love.graphics.print txt 12 (+ 12 (* offset 18)))))
 :update (fn [])
 :activate (fn [new] (set which new))
 :keypressed (fn [key set-mode]
               (if (= key "up")
                   (set offset (math.max 0 (- offset 1)))
                   (= key "down")
                   (set offset (math.min 16 (+ offset 1)))
                   (or (= key "return") (= key "escape"))
                   (set-mode :play)))}
