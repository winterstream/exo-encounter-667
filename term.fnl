(local lume (require "lib.lume"))

(local font (love.graphics.newFont "assets/FSEX300.ttf" 16))
(local bg (love.graphics.newImage "assets/term.bmp"))

(var lines (lume.split (love.filesystem.read "text/first") "\n"))
(var offset 0)

{:draw (fn []
         (love.graphics.setColor 0.8 0.8 0.8)
         (love.graphics.draw bg 0 0)
         (love.graphics.setColor 0 0.7 0)
         (for [i 1 12]
           (love.graphics.print (or (. lines (+ offset i)) "")
                                12 (- (* i 18) 9))))
 :update (fn [])
 :activate (fn [which]
             (love.graphics.setFont font)
             (set lines (lume.split (love.filesystem.read (.. "text/" which))
                                    "\n")))
 :keypressed (fn [key set-mode]
               (if (= key "up")
                   (set offset (math.max 0 (- offset 1)))
                   (= key "down")
                   (when (< offset (- (# lines) 12))
                     (set offset (math.min 16 (+ offset 1))))
                   (or (= key "return") (= key "escape"))
                   (set-mode :play)))}
