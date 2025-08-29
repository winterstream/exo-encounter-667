(local camera-tracking-system (require :src.systems.camera-tracking-system))
(local tutorial-system (require :src.systems.tutorial-system))

(local state (require :state))
(local play (require :play))

(local camera (camera-tracking-system state))
(local tutorial (tutorial-system state))

{:draw (fn [] (play.draw))
 :update (fn [dt set-mode]
           (camera:update dt)
           (tutorial:update dt)
           (play.update dt set-mode))
 :keypressed (fn [key set-mode]
               (play.keypressed key set-mode))}
