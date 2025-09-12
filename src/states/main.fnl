(local bump (require :lib.bump))
(local tiled (require :lib.tiled))

(local autopilot-system (require :src.systems.autopilot-system))
(local bump-physics-system (require :src.systems.bump-physics-system))
(local camera-tracking-system (require :src.systems.camera-tracking-system))
(local door-update-system (require :src.systems.door-update-system))
(local docking-system (require :src.systems.docking-system))
(local hud-system (require :src.systems.hud-system))
(local laser-control-system (require :src.systems.laser-control-system))
(local player-control-system (require :src.systems.player-control-system))
(local rover-labeling-system (require :src.systems.rover-labeling-system))
(local tile-map-render-system (require :src.systems.tile-map-render-system))
(local tutorial-system (require :src.systems.tutorial-system))

(local draw (require :src.draw))
(local lint (require :src.lint))
(local state (require :src.state))

(local rovers [{:theta 0 :docked? true :type :rover :vx 0 :vy 0}
               {:theta 3 :docked? false :type :rover :vx 0 :vy 0}
               {:theta 2 :docked? false :type :rover :vx 0 :vy 0}
               {:theta 0 :docked? true :type :rover :vx 0 :vy 0}])

(local probe {:theta math.pi :type :probe :rovers [] :vx 0 :vy 0})

(local map (lint (tiled :map.lua [:bump])))
(local world (bump.newWorld))

(set state.rovers rovers)
(set state.probe probe)
(set state.map map)
(set state.world world)
(set state.selected probe)

(map:bump_init world)
(world:add probe 105 1205 30 24)
(world:add (. rovers 2) 165 1200 10 10)

; start undocked
(world:add (. rovers 3) 145 1212 10 10)

;; set up custom layers which aren't preloaded in the map
(let [layer (state.map:addCustomLayer :player 8)]
  (set layer.sprites [(unpack state.rovers)])
  (tset layer.sprites 0 state.probe)
  (set layer.draw (partial draw.player state.world state)))

;; layers where we change the drawing of the sprites based on gameplay can't
;; be drawn by tiled; we have to write our own draw.
(set state.map.layers.sensors.draw draw.sensors)
(set state.map.layers.doors.draw draw.doors)

(local draw-systems [(tile-map-render-system state)
                     (rover-labeling-system state)
                     (hud-system state)])

(local update-systems [(autopilot-system state)
                       (bump-physics-system state)
                       (camera-tracking-system state)
                       (door-update-system state)
                       (docking-system state)
                       (hud-system state)
                       (laser-control-system state)
                       (player-control-system state)
                       (rover-labeling-system state)
                       (tutorial-system state)])

{:draw (fn [dt]
         (each [_ system (ipairs draw-systems)]
           (system:update dt)))
 :update (fn [dt set-mode]
           (each [_ system (ipairs update-systems)]
             (system:update dt set-mode)))
 :keypressed (fn [key set-mode]
               (if (or (= key :escape) (= key :f1)) (set-mode :pause)))}
