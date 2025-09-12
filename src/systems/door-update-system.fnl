(local class (require :lib.30log))
(local lume (require :lib.lume))

(local sound (require :sound))

(local door-update-system (class :door-update-system))

;; immobilize units when the door closes on them
(fn immobilize [map world door]
  (let [(x y w h) (map.bump_wrap :getRect door)
        items (world:queryRect x y w h)]
    (each [_ item (ipairs items)]
      (when (or (= :rover item.type) (= :probe item.type))
        (set item.immobilized? true)))))

;; it's important to distinguish between "begin to open/close" vs
;; "completed opening/closing"; collision changes happen on completion
;; of opening but beginning of closing. these 2 functions are completion ones.
(fn open [map world door]
  ;; we can't use an object from the map directly with the bump world,
  ;; because the map wraps it in another table, so we have to go thru
  ;; our hacked addition to the map which looks up the wrapper and
  ;; uses that instead.
  ;; see https://github.com/karai17/Simple-Tiled-Implementation/issues/180
  (when (map.bump_wrap :hasItem door)
    (let [(x y w h) (map.bump_wrap :getRect door)
          items (world:queryRect x y w h)]
      (map.bump_wrap :remove door)
      (each [_ item (ipairs items)]
        (when (or (= :rover item.type) (= :probe item.type))
          (set item.immobilized? false)))))
  (lume.extend door.properties {:level 1
                                :open true
                                :closing false
                                :opening false}))

(fn close [_map door]
  (lume.extend door.properties {:level 0
                                :open false
                                :closing false
                                :opening false}))

(fn update-door [map world door dt]
  (when door.properties.opening
    (set door.properties.level (+ (or door.properties.level 0) dt))
    (when (> door.properties.level 1)
      (open map world door)))
  (when door.properties.closing
    (when (not (map.bump_wrap :hasItem door))
      (map.bump_wrap :add door door.x (- door.y 61) door.width 61)
      (immobilize map world door))
    (set door.properties.level (- (or door.properties.level 1) dt))
    (when (> 0 door.properties.level)
      (close map door))))

(fn door-update-system.init [self state]
  (set self.state state))

(fn door-update-system.update [self dt]
  (var in-motion? false)
  (each [_ door (ipairs self.state.map.layers.doors.objects)]
    (update-door self.state.map self.state.world door dt)
    (when (or door.properties.opening door.properties.closing)
      (set in-motion? true)))
  (when (not in-motion?) (sound.stop :door)))

door-update-system
