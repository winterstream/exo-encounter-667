(local hud (require :hud))

(local small-font (love.graphics.newFont :assets/FSEX300.ttf 12))

(local probe-img (love.graphics.newImage :assets/probe.png))
(local sensor-img (love.graphics.newImage :assets/sensor.png))
(local sensor-on-img (love.graphics.newImage :assets/sensor-on.png))
(local sensor-m-on-img (love.graphics.newImage :assets/sensor-m-on.png))
(local sensor-m-img (love.graphics.newImage :assets/sensor-m.png))
(local door-below-img (love.graphics.newImage :assets/door-below.png))
(local door-img (love.graphics.newImage :assets/door-open.png))

(fn draw-rover [rect theta selected? docked?]
  (let [[corner-x corner-y w] rect
        radius (/ w 2)
        center-x (+ corner-x radius)
        center-y (+ corner-y radius)
        x2 (+ center-x (* (math.cos theta) radius))
        y2 (+ center-y (* (math.sin theta) radius))]
    (when (not docked?)
      (love.graphics.setColor 0 0 0)
      (love.graphics.circle :line center-x center-y radius))
    (if selected?
        (love.graphics.setColor 0.5 0.5 0.5)
        (love.graphics.setColor 0.2 0.2 0.2))
    (love.graphics.circle :fill center-x center-y radius)
    ;; forward indicator
    (love.graphics.setColor 0.1 0.1 0.1)
    (love.graphics.line center-x center-y x2 y2)
    ;; mirror indicator
    (let [perpendicular (+ theta (/ math.pi 2))
          px1 (+ center-x (* (math.cos perpendicular) radius 0.8))
          py1 (+ center-y (* (math.sin perpendicular) radius 0.8))
          px2 (- center-x (* (math.cos perpendicular) radius 0.8))
          py2 (- center-y (* (math.sin perpendicular) radius 0.8))]
      (love.graphics.line px1 py1 px2 py2))))

(fn label-rover [world rover number selected?]
  (when (and (not selected?) (not rover.docked?))
    (let [(x y) (: world :getRect rover)]
      (love.graphics.print number (+ x 2) (- y 2)))))

(local offsets [[-5 -5] [25 -5] [25 19] [-5 19]])

(fn docked-rect [prect i]
  (let [[px py] prect
        [ox oy] (. offsets i)]
    [(+ px ox) (+ py oy) 10 10]))

(fn draw-probe [rect selected?]
  (if selected?
      (love.graphics.setColor 1 1 1)
      (love.graphics.setColor 0.8 0.8 0.8))
  (let [[x y] rect]
    (love.graphics.draw probe-img (math.floor x) (math.floor y))))

(fn laser [laser]
  (love.graphics.setColor 1 0 0)
  (each [_ segment (ipairs laser)]
    (love.graphics.line (unpack segment))))

(fn player [world state]
  (let [prect [(: world :getRect state.probe)]]
    (each [i rover (ipairs state.rovers)]
      (let [rect (if rover.docked?
                     (docked-rect prect i)
                     [(: world :getRect rover)])]
        (draw-rover rect rover.theta (= state.selected rover) rover.docked?)))
    (draw-probe prect (= state.probe state.selected)))
  (when state.laser
    (laser state.laser)))

;; Ideally we could just let the tiled lib draw this, but there seems to be
;; no way to change an object's sprite at runtime?
(fn sensors [layer]
  (each [_ sensor (ipairs layer.objects)]
    (let [img (if (and sensor.properties.momentary sensor.properties.on)
                  sensor-m-on-img
                  sensor.properties.momentary
                  sensor-m-img
                  sensor.properties.on
                  sensor-on-img
                  sensor-img)]
      (love.graphics.draw img sensor.x (- sensor.y sensor.height)))))

(fn doors [layer]
  (each [_ door (ipairs layer.objects)]
    (love.graphics.draw door-below-img door.x (- door.y 21))
    (let [y (- 21 (* (or door.properties.level 0) 21))]
      (love.graphics.draw door-img door.x (- door.y door.height y)))))

(fn draw [map world state]
  (: map :draw (- state.tx) (- state.ty))
  (love.graphics.push)
  ;; drawing non-map stuff needs to apply our own translate
  (love.graphics.translate (- state.tx) (- state.ty))
  (love.graphics.setColor 1 1 1)
  (love.graphics.setFont small-font)
  (each [i rover (ipairs state.rovers)]
    (label-rover world rover i (= rover state.selected)))
  (love.graphics.pop)
  (hud.draw state))

{: draw : player : sensors : doors}
