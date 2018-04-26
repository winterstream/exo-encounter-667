(local door-names {})

(fn [map]
  (each [_ door (ipairs map.layers.doors.objects)]
    (tset door-names door.name true)
    (assert door.properties.collidable "Missing door collidable!"))
  (each [_ sensor (ipairs map.layers.sensors.objects)]
    (assert sensor.properties.collidable "Missing sensor collidable!")
    (assert sensor.properties.door "Missing sensor door!")
    (assert (. door-names sensor.properties.door)
            (.. "Unknown door:" sensor.properties.door))
    (set sensor.properties.sensor true))
  (each [_ term (ipairs map.layers.terms.objects)]
    (print :term term)
    (assert term.properties.collidable "Missing term collidable!")
    (assert term.properties.terminal "Missing term text!")
    (assert (love.filesystem.isFile (.. "text/" term.properties.terminal)))))
