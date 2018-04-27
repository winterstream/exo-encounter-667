(local intro-img (love.graphics.newImage "assets/intro-225.jpg"))
(local intro-font (love.graphics.newFont "assets/FSEX300.ttf" 32))
(local small-font (love.graphics.newFont "assets/FSEX300.ttf" 12))
(local font (love.graphics.newFont "assets/FSEX300.ttf" 16))

(local messages
       [["MISSION: initial unmanned expedition to Gliese 667"]
        ["WARNING: extreme radiation storm approaching"]
        ["CRITICAL: detected failure in lander engines"]
        ["STATUS: lander crash; 352 meters southwest of target site"]])

(: intro-img :setFilter "nearest")

(var counter 0)

{:draw (fn [message]
         (love.graphics.setFont intro-font)
         (love.graphics.draw intro-img)
         (love.graphics.print "EXO_encounter 667" 32 16)
         (love.graphics.setFont small-font)
         (if message
             (love.graphics.print message 16 72)
             (for [i 1 (# messages)]
               (when (> counter (* i 2))
                 (love.graphics.print (. messages i) 8 (+ (* 18 i) 120))))))
 :update (fn [dt set-mode]
           (set counter (+ counter dt))
           (when (> counter (if (os.getenv "QUICK") 1 16))
             (love.graphics.setFont font)
             (set-mode :play)))
 :keypressed (fn [key set-mode]
               (if (= key "space")
                   (set counter (if (> counter 8)
                                    (do (love.graphics.setFont font)
                                        (set-mode :play))
                                    (* 2 (math.ceil (/ counter 2)))))
                   (do (love.graphics.setFont font)
                       (set-mode :play))))}
