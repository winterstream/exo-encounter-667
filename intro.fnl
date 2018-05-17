(local intro-img (love.graphics.newImage "assets/intro-225.jpg"))
(local intro-font (love.graphics.newFont "assets/FSEX300.ttf" 32))
(local small-font (love.graphics.newFont "assets/FSEX300.ttf" 12))

(local messages (lume.split (love.filesystem.read "text/splash") "\n"))

(var counter 0)

{:draw (fn draw [message]
         (love.graphics.setFont intro-font)
         (love.graphics.draw intro-img)
         (love.graphics.print "EXO_encounter 667" 32 16)
         (love.graphics.setFont small-font)
         (if message
             ;; let this code be re-used by pause/help mode
             (love.graphics.print message 16 62)
             (for [i 1 (# messages)]
               (when (> counter (* i 2))
                 (love.graphics.print (. messages i) 8 (+ (* 18 i) 110))))))
 :update (fn update [dt set-mode]
           (set counter (+ counter dt))
           (when (> counter 16)
             (set-mode :play)))
 :keypressed (fn keypressed [key set-mode]
               (if (= key "space")
                   (set counter (if (> counter 8)
                                    (set-mode :play)
                                    (* 2 (math.ceil (/ counter 2)))))
                   (set-mode :play)))}
