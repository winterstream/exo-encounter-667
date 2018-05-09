;; sensors are represented in tiled as any item on the "sensor" layer.
;; they must have the collidable property set to work. they must have
;; a "door" property which corresponds to the name of a door object.

(local lume (require "lib.lume"))
(local sound (require "sound"))

(fn finder [name] (fn [d] (= d.name name)))

;; when a rover gets stuck in a door that's closed, set immobilized?
(fn immobilize [map world door]
  (let [(x y w h) (map.bump_wrap :getRect door)
        items (: world :queryRect x y w h)]
    (each [_ item (ipairs items)]
      (when (or (= :rover item.type) (= :probe item.type))
        (set item.immobilized? true)))))

(fn open [map world door]
  ;; we can't use an object from the map directly with the bump world,
  ;; because the map wraps it in another table, so we have to go thru
  ;; our hacked addition to the map which looks up the wrapper and
  ;; uses that instead.
  (when (map.bump_wrap :hasItem door)
    (let [(x y w h) (map.bump_wrap :getRect door)
          items (: world :queryRect x y w h)]
      (map.bump_wrap :remove door)
      (each [_ item (ipairs items)]
        (when (or (= :rover item.type) (= :probe item.type))
          (set item.immobilized? false)))))
  (lume.extend door.properties
               {:level 1 :open true :closing false :opening false}))

(fn close [_map door]
  (lume.extend door.properties
               {:level 0 :open false :closing false :opening false}))

(fn on [map item]
  (set item.properties.on true)
  (when item.properties.door
    (let [door (lume.match map.layers.doors.objects
                           (finder item.properties.door))]
      (sound.play :door)
      (set door.properties.opening true)
      (set door.properties.hit true))))

(fn update-door [map world door dt]
  (when door.properties.opening
    (set door.properties.level (+ (or door.properties.level 0) dt))
    (when (> door.properties.level 1)
      (open map world door)))
  (when door.properties.closing
    ;; Don't add it back when it finishes closing but when it starts
    (when (not (map.bump_wrap :hasItem door))
                                        ; ???
      (map.bump_wrap :add door door.x (- door.y 61) door.width 61)
      (immobilize map world door))
    (set door.properties.level (- (or door.properties.level 1) dt))
    (when (> 0 door.properties.level)
      (close map door))))

(fn update-sensor [map sensor]
  (when sensor.properties.momentary
    (let [door (lume.match map.layers.doors.objects
                           (finder sensor.properties.door))]
      (set door.properties.closing (not door.properties.hit))
      (when door.properties.closing
        (when door.properties.open
          (sound.play :door))
        (set door.properties.opening false))
      ;; set it to false at the end of the update call; the laser
      ;; check will happen later this tick, and then we'll check it
      ;; again in the next tick.
      (set door.properties.hit false))
    ;; each momentary sensor starts the tick as off
    (set sensor.properties.on false)))

{:is? (fn is [item] (and item.properties item.properties.sensor))
 :on on
 :update (fn update [_state map world dt]
           (var in-motion? false)
           (each [_ door (ipairs map.layers.doors.objects)]
             (update-door map world door dt)
             (when (or door.properties.opening door.properties.closing)
               (set in-motion? true)))
           (when (not in-motion?)
             (sound.stop :door))
           (each [_ sensor (ipairs map.layers.sensors.objects)]
             (update-sensor map sensor)))}
