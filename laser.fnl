(local lume (require "lib.lume"))
(local intersect (require "lib.intersect"))
(local sensor (require "sensor"))
;; this is the max range only for each segment individually; no total limit
(local range 360)

(defn reflective? [item] (= item.type :rover))

(defn transparent? [item]
  (let [layer-name (and item.layer item.layer.name)]
    (or (= layer-name :obstacles)
        (= layer-name :terms))))

;; a line segment for the mirror of a rover
(defn mirror-segment [world rover mirror-theta]
  (let [(x y w) (: world :getRect rover)
        radius (/ w 2)
        center-x (+ x radius)
        center-y (+ y radius)
        x1 (+ center-x (* (math.cos mirror-theta) radius))
        y1 (+ center-y (* (math.sin mirror-theta) radius))
        x2 (- center-x (* (math.cos mirror-theta) radius))
        y2 (- center-y (* (math.sin mirror-theta) radius))]
    [x1 y1 x2 y2]))

(defn normalize-angle [inbound-theta mirror-theta]
  (let [normalized-inbound (- inbound-theta mirror-theta)
        normalized-outbound (- normalized-inbound)
        outbound (+ normalized-outbound mirror-theta)]
    outbound))

;; returns the point where it hits the mirror and the outbound angle
(defn reflect [world x1 y1 x2 y2 inbound-theta item]
  (let [mirror-theta (+ item.theta (/ math.pi 2))
        [mx1 my1 mx2 my2] (mirror-segment world item mirror-theta)
        (x y) (intersect x1 y1 x2 y2 mx1 my1 mx2 my2)]
    ;; just because the laser crossed the body doesn't mean it hit mirror
    (if x (values x y (normalize-angle inbound-theta mirror-theta)))))

{:fire (fn fire [x y theta world map segments ignore limit]
         (let [far-x (+ x (* (math.cos theta) range))
               far-y (+ y (* (math.sin theta) range))
               filter (fn [item] (not (lume.find ignore item)))
               [hit] (: world :querySegmentWithCoords x y far-x far-y filter)]
           (if (and hit (> limit 0))
               (if (reflective? hit.item)
                   (let [(new-x new-y theta2) (reflect world x y hit.x2 hit.y2
                                                       theta hit.item)]
                     (if theta2
                         (do (table.insert segments [x y new-x new-y])
                             (fire new-x new-y theta2 world map segments
                                   [hit.item] (- limit 1)))
                         (do (table.insert ignore hit.item)
                             (fire x y theta world map segments ignore limit))))

                   (sensor.is? hit.item)
                   (do (sensor.on map hit.item)
                       (table.insert segments [x y hit.x1 hit.y1])
                       segments)

                   (transparent? hit.item)
                   (do (table.insert ignore hit.item)
                       (fire x y theta world map segments ignore limit))

                   (do (table.insert segments [x y hit.x1 hit.y1])
                       segments))
               (do (table.insert segments [x y far-x far-y])
                   segments))))}
