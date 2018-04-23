;; sensors are represented in tiled as any item on the "sensor" layer.
;; they must have the collidable property set to work.

(local door (require "door"))

(defn activate [world map item]
  (set item.properties.on true)
  (when item.properties.door
    (door.open map item.properties.door)))

{:is? (fn [item] (and item.properties item.properties.sensor))
 :activate activate
 :update (fn [state map dt]
           ;; each sensor starts the tick as off
           (each [_ sensor (ipairs map.layers.sensors.objects)]
             (set sensor.properties.on false)))
 :init (fn [state map]
         (each [_ sensor (ipairs map.layers.sensors.objects)]
           (assert sensor.properties.collidable "Missing sensor collidable!")
           (set sensor.properties.sensor true)))}
