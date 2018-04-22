;; this is the max range only for each segment individually; no total limit
(local range 720)

(defn reflective? [item] (= item.type :rover))

;; oops; this is only needed for reflecting off AABBs
(defn reflect-theta-aabb [world hit theta]
  (let [(x y w h) (: world :getRect hit.item)]
    (if (or (= hit.x1 x) (= hit.x1 (+ x w))) ; left/right
        (- theta)
        (or (= hit.y1 y) (= hit.y1 (+ y h))) ; top/bottom
        (- math.pi theta))))

(defn reflect-mirror [world hit incoming]
  (let [normalized (- incoming hit.item.theta)
        reflected (- normalized)
        absolutized (+ reflected hit.item.theta)]
    absolutized))

{:fire (fn fire [x y theta world segments from limit]
         (let [x2 (+ x (* (math.cos theta) range))
               y2 (+ y (* (math.sin theta) range))
               filter (fn [item] (~= item from))
               [hit] (: world :querySegmentWithCoords x y x2 y2 filter)]
           (if (and hit (> limit 0))
               (let [theta2 (reflect-mirror world hit theta)]
                 (table.insert segments [x y hit.x1 hit.y1])
                 (if (reflective? hit.item)
                     (fire hit.x1 hit.y1 theta2 world
                           segments hit.item (- limit 1))
                     segments))
               (do (table.insert segments [x y x2 y2])
                   segments))))}
