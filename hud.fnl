(local font (love.graphics.newFont "assets/FSEX300.ttf" 16))
(local tutorial (require "tutorial"))

{:draw (fn draw [state]
         (love.graphics.setFont font)
         (love.graphics.setColor 1 1 1)
         (when state.probe.stuck?
           (love.graphics.print "Immobile; dock at least 3 rovers" 26 4))
         (for [i 1 5] ; show the most recent 5 messages
           (love.graphics.print (or (. state.messages i) "")
                                10 (- 213 (* 18 i))))
         ;; rover deploy indicators
         (each [i rover (ipairs state.rovers)]
           (if (= state.selected rover)
               (love.graphics.setColor 0.7 1 0.7)
               rover.docked?
               (love.graphics.setColor 1 1 1)
               (love.graphics.setColor 0.5 0.5 0.5))
           (let [x 4 y (- (* i 22) 18) w 18]
             (love.graphics.rectangle "line" x (- y 2) w w)
             (love.graphics.print (tostring i) 6 y)))
         (love.graphics.rectangle "line" 4 105 18 18)
         ;; laser aiming vector
         (love.graphics.setColor 1 0 0)
         (let [lx (+ 13 (* (math.cos state.probe.theta) 8))
               ly (+ 114 (* (math.sin state.probe.theta) 8))]
           (love.graphics.line 13 114 lx ly)))
 :update tutorial.update}
