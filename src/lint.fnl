;; check for common map errors

(local door-names {})

(fn lint [map]
  (each [_ door (ipairs map.layers.doors.objects)]
    (tset door-names door.name true))
  (each [_ sensor (ipairs map.layers.sensors.objects)]
    (assert sensor.properties.door (.. "Missing sensor door:" sensor.name))
    (assert (. door-names sensor.properties.door)
            (.. "Unknown door:" sensor.properties.door))
    (set sensor.properties.sensor true))
  (each [_ splitter (ipairs map.layers.splitters.objects)]
    (assert splitter.properties.splitter "Missing splitter property!"))
  (each [_ term (ipairs map.layers.terms.objects)]
    (assert term.properties.collidable "Missing term collidable!")
    (assert term.properties.terminal "Missing term text!")
    (assert (love.filesystem.getInfo (.. :text/ term.properties.terminal))))
  map)
