;; sensors are represented in tiled as any item on the "sensor" layer.
;; they must have the collidable property set to work. they must have
;; a "door" property which corresponds to the name of a door object.
;; momentary doors close in any tick that their sensor isn't active.

(local class (require :lib.30log))
(local lume (require :lib.lume))

(local sound (require :sound))

(local sensor-update-system (class :sensor-update-system))

(fn update-sensor [map sensor]
  (when sensor.properties.momentary
    (let [door (lume.match map.layers.doors.objects
                           (fn [name] #(= $.name name)))]
      ;; begin to close, if not hit
      (set door.properties.closing (not door.properties.hit))
      (when door.properties.closing
        (when door.properties.open (sound.play :door))
        (set door.properties.opening false))
      ;; set hit to false at the end of the update call; the laser
      ;; check will happen later this tick, and then we'll check it
      ;; again in the next tick. same with the sensor.
      (set door.properties.hit false)
      (set sensor.properties.on false))))

(fn sensor-update-system.init [self state]
  (set self.state state))

(fn sensor-update-system.update [self]
  (each [_ sensor (ipairs self.state.map.layers.sensors.objects)]
    (update-sensor self.state.map sensor)))

sensor-update-system
