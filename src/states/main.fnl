(local play (require :play))

{:draw (fn [] (play.draw))
 :update (fn [dt set-mode]
           (play.update dt set-mode))
 :keypressed (fn [key set-mode]
               (play.keypressed key set-mode))}
