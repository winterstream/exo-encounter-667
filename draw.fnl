(local font (love.graphics.newFont "assets/FSEX300.ttf" 16))
(local sensor-img (love.graphics.newImage "assets/sensor.png"))
(local sensor-on-img (love.graphics.newImage "assets/sensor-on.png"))

(defn draw-rover [i rover world state]
  (if (= rover state.selected)
      (love.graphics.setColor 0.5 0.5 0.5)
      (love.graphics.setColor 0.2 0.2 0.2))
  (let [(corner-x corner-y w h) (: world :getRect rover)
        radius (/ w 2)
        center-x (+ corner-x radius)
        center-y (+ corner-y radius)
        x2 (+ center-x (* (math.cos rover.theta) radius))
        y2 (+ center-y (* (math.sin rover.theta) radius))]
    (love.graphics.circle "fill" center-x center-y radius)
    ;; forward indicator
    (love.graphics.setColor 0.1 0.1 0.1)
    (love.graphics.line center-x center-y x2 y2)
    ;; mirror indicator
    (let [perpendicular (+ rover.theta (/ math.pi 2))
          px1 (+ center-x (* (math.cos perpendicular) radius 0.8))
          py1 (+ center-y (* (math.sin perpendicular) radius 0.8))
          px2 (- center-x (* (math.cos perpendicular) radius 0.8))
          py2 (- center-y (* (math.sin perpendicular) radius 0.8))]
      (love.graphics.line px1 py1 px2 py2))))

(defn draw-probe [world probe selected?]
  (if selected?
      (love.graphics.setColor 0.4 0.4 0.4)
      (love.graphics.setColor 0.3 0.3 0.3))
  (love.graphics.rectangle "fill" (: world :getRect probe)))

(defn draw-laser [laser]
  (love.graphics.setColor 1 0 0)
  (each [_ segment (ipairs laser)]
    (love.graphics.line (unpack segment))))

{:draw (fn [map world state]
         (: map :draw state.tx state.ty)
         (love.graphics.push)
         ;; drawing non-map stuff needs to apply our own translate
         (love.graphics.translate state.tx state.ty)
         (when state.laser
           (draw-laser state.laser))
         (love.graphics.pop))
 ;; this gets called by the tiled library at the right time so other
 ;; layers can obscure it when necessary
 :draw-player (fn [world state]
                (each [i rover (ipairs state.rovers)]
                  (draw-rover i rover world state))
                (draw-probe world state.probe (= state.probe state.selected)))
 ;; Ideally we could just let the tiled lib draw this, but there seems to be
 ;; no way to change an object's sprite at runtime?
 :draw-sensors (fn [layer]
                 (each [_ sensor (ipairs layer.objects)]
                   (love.graphics.draw (if sensor.properties.on
                                           sensor-on-img sensor-img)
                                       sensor.x sensor.y)))}
