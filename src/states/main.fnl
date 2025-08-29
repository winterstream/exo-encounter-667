(local tutorial-system (require :src.systems.tutorial-system))

(local state (require :state))
(local play (require :play))

(local tutorial (tutorial-system state))

{:draw (fn [] (play.draw))
 :update (fn [dt set-mode]
           (tutorial:update dt)
           (play.update dt set-mode))
 :keypressed (fn [key set-mode]
               (play.keypressed key set-mode))}
