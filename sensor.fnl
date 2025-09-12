;; sensors are represented in tiled as any item on the "sensor" layer.
;; they must have the collidable property set to work. they must have
;; a "door" property which corresponds to the name of a door object.
;; momentary doors close in any tick that their sensor isn't active.

(local lume (require :lib.lume))

(local sound (require :sound))

(fn finder [name] (fn [d] (= d.name name)))

(fn on [map item]
  (set item.properties.on true)
  (when item.properties.door
    (let [door (lume.match map.layers.doors.objects
                           (finder item.properties.door))]
      ;; begin to open
      (sound.play :door)
      (set door.properties.opening true)
      (set door.properties.hit true))))

(fn update-sensor [map sensor]
  (when sensor.properties.momentary
    (let [door (lume.match map.layers.doors.objects
                           (finder sensor.properties.door))]
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

{:is? (fn [item]
        (and item.properties item.properties.sensor))
 : on
 :update (fn [_state map world dt]
           (each [_ sensor (ipairs map.layers.sensors.objects)]
             (update-sensor map sensor)))}
