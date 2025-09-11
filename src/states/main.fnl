(local autopilot-system (require :src.systems.autopilot-system))
(local bump-physics-system (require :src.systems.bump-physics-system))
(local camera-tracking-system (require :src.systems.camera-tracking-system))
(local laser-control-system (require :src.systems.laser-control-system))
(local player-control-system (require :src.systems.player-control-system))
(local tutorial-system (require :src.systems.tutorial-system))

(local state (require :state))
(local play (require :play))

(local autopilot (autopilot-system state))
(local bump-physics (bump-physics-system state))
(local camera (camera-tracking-system state))
(local laser (laser-control-system state))
(local player-control (player-control-system state))
(local tutorial (tutorial-system state))

{:draw (fn [] (play.draw))
 :update (fn [dt set-mode]
           (camera:update dt set-mode)
           (tutorial:update dt set-mode)
           (player-control:update dt set-mode)
           (autopilot:update dt set-mode)
           (bump-physics:update dt set-mode)
           (laser:update dt set-mode)
           (play.update dt set-mode))
 :keypressed (fn [key set-mode]
               (play.keypressed key set-mode))}
