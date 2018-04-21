;; this is the max range only for each segment individually; no total limit
(local range 720)

(defn not-probe? [item] (~= item.type :probe))
(defn opaque? [item] true) ; in the future, certain items will be transparent?
(defn reflective? [item] (= item.type :rover))

;; oops; this is only needed for reflecting off AABBs
(defn reflect-theta-aabb [world hit theta]
  (let [(x y w h) (: world :getRect hit.item)]
    (if (or (= hit.x1 x) (= hit.x1 (+ x w))) ; left/right
        (- theta)
        (or (= hit.y1 y) (= hit.y1 (+ y h))) ; top/bottom
        (- math.pi theta))))

(defn reflect-mirror [world hit incoming]
  (let [mirror-theta (- hit.item.theta (/ math.pi 2))]
    ;; this is not close to correct
    (- (- incoming) mirror-theta)))

{:fire (fn fire [x y theta world segments limit]
         (let [x2 (+ x (* (math.cos theta) range))
               y2 (+ y (* (math.sin theta) range))
               filter (if (= (# segments) 0)
                          not-probe?
                          opaque?)
               [hit] (: world :querySegmentWithCoords x y x2 y2 filter)]
           (if (and hit (> limit 0))
               (let [theta2 (reflect-mirror world hit theta)]
                 (print :hit x y hit.x1 hit.y1)
                 (table.insert segments [x y hit.x1 hit.y1])
                 (if (reflective? hit.item)
                     (fire hit.x1 hit.y1 theta2 world segments (- limit 1))
                     segments))
               (do (print :no-hit x y x2 y2)
                   (table.insert segments [x y x2 y2])
                   segments))))}
