(local draw (require :draw))
(local sensor (require :sensor))

(local state (require :state))

(local map state.map)
(local world state.world)

(set state.selected state.probe)

;; set up custom layers which aren't preloaded in the map
(let [layer (map:addCustomLayer :player 8)]
  (set layer.sprites [(unpack state.rovers)])
  (tset layer.sprites 0 state.probe)
  (set layer.draw (partial draw.player world state)))

;; layers where we change the drawing of the sprites based on gameplay can't
;; be drawn by tiled; we have to write our own draw.
(set map.layers.sensors.draw draw.sensors)
(set map.layers.doors.draw draw.doors)

(fn update [dt set-mode]
  ;; controls
  (sensor.update state map world dt))

{:draw (fn []) : update}
