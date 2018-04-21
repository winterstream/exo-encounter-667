;; this is the max range only for each segment individually; no total limit
(local range 720)

(defn filter [item] (~= item.type :probe))

(defn reflect-theta [hit theta]
  (if (or (= hit.x1 hit.item.x) ; left/right
          (= hit.x1 (+ hit.item.x (or hit.item.width (* hit.item.radius 2)))))
      (- theta)
      (or (= hit.y1 hit.item.y) ; top/bottom
          (= hit.y1 (+ hit.item.y (or hit.item.height (* hit.item.radius 2)))))
      (- math.pi theta)))

;; TODO: fennel defn doesn't allow recursion
(local fire (fn fire [x y theta world segments]
              (let [x2 (+ x (* (math.cos theta) range))
                    y2 (+ y (* (math.sin theta) range))
                    [hit] (: world :querySegmentWithCoords x y x2 y2 filter)]
                (if hit
                    (let [theta2 (reflect-theta hit theta)]
                      (table.insert segments [x y hit.x1 hit.y1])
                      (if (= hit.item.type :rover)
                          (fire x2 y2 theta2 world segments)
                          segments))
                    (do (table.insert segments [x y x2 y2])
                        segments)))))

{:fire fire}
