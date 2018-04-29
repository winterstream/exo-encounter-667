;; sensors are represented in tiled as any item on the "sensor" layer.
;; they must have the collidable property set to work.

(local lume (require "lib.lume"))

(defn finder [name] (fn [d] (= d.name name)))

(defn open [map door]
  ;; we can't use an object from the map directly with the bump world, because
  ;; the map wraps it in another table, so we have to go thru our hacked
  ;; addition to the map which looks up the wrapper and uses that instead.
  (when (not door.properties.open)
    (map.bump_wrap :remove door))
  (set door.properties.open true))

(defn close [map world door]
  ;; TODO: hitbox for momentary doors starts off too small; gets fixed after
  ;; first open/close cycle.
  (when door.properties.open        ; ???
    (map.bump_wrap :add door door.x (- door.y 61) door.width 61))
  (set door.properties.open false))

(defn on [map item]
  (set item.properties.on true)
  (when item.properties.door
    (let [d (lume.match map.layers.doors.objects (finder item.properties.door))]
      (open map d))))

{:is? (fn [item] (and item.properties item.properties.sensor))
 :on on
 :update (fn [_state map world _dt]
           (each [_ sensor (ipairs map.layers.sensors.objects)]
             (when sensor.properties.momentary
               (close map world (lume.match map.layers.doors.objects
                                            (finder sensor.properties.door))))
             ;; each sensor starts the tick as off
             (set sensor.properties.on false)))}
