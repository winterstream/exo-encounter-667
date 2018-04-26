;; sensors are represented in tiled as any item on the "sensor" layer.
;; they must have the collidable property set to work.

(local lume (require "lib.lume"))

(defn open [map door]
  (set door.properties.open true)
  ;; we can't use an object from the map directly with the bump world, because
  ;; the map wraps it in another table, so we have to go thru our hacked
  ;; addition to the map which looks up the wrapper and uses that instead.
  (when (map.bump_wrap :hasItem door)
    (map.bump_wrap :remove door)))

(defn on [map item]
  (set item.properties.on true)
  (when item.properties.door
    (let [d (lume.match map.layers.doors.objects
                        (fn [d] (= d.name item.properties.door)))]
      (open map d))))

{:is? (fn [item] (and item.properties item.properties.sensor))
 :on on
 :update (fn [_state map]
           ;; each sensor starts the tick as off
           (each [_ sensor (ipairs map.layers.sensors.objects)]
             (set sensor.properties.on false)))}
