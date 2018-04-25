(local anim8 (require "lib.anim8"))

(local probe-img (love.graphics.newImage "assets/probe.png"))
(local sensor-img (love.graphics.newImage "assets/sensor.png"))
(local sensor-on-img (love.graphics.newImage "assets/sensor-on.png"))
(local door-img (love.graphics.newImage "assets/door.png"))
(local door-open-img (love.graphics.newImage "assets/door-open.png"))
(local term-img (love.graphics.newImage "assets/termpad.png"))
(local term-grid (anim8.newGrid 40 61 (: term-img :getWidth)
                                (: term-img :getHeight)))
(local term-anim (anim8.newAnimation (term-grid "1-5" 1) 0.1))

(defn draw-rover [rover world state]
  (let [(corner-x corner-y w) (: world :getRect rover)
        radius (/ w 2)
        center-x (+ corner-x radius)
        center-y (+ corner-y radius)
        x2 (+ center-x (* (math.cos rover.theta) radius))
        y2 (+ center-y (* (math.sin rover.theta) radius))]
    (love.graphics.setColor 0 0 0)
    (love.graphics.circle "line" center-x center-y radius)
    (if (= rover state.selected)
      (love.graphics.setColor 0.5 0.5 0.5)
      (love.graphics.setColor 0.2 0.2 0.2))
    (love.graphics.circle "fill" center-x center-y (- radius 1))
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
      (love.graphics.setColor 1 1 1)
      (love.graphics.setColor 0.8 0.8 0.8))
  (let [(x y) (: world :getRect probe)]
    (love.graphics.draw probe-img (math.floor x) (math.floor y))))

(defn draw-laser [laser]
  (love.graphics.setColor 1 0 0)
  (each [_ segment (ipairs laser)]
    (love.graphics.line (unpack segment))))

{:draw (fn [map _world state]
         (: map :draw state.tx state.ty)
         (love.graphics.push)
         ;; drawing non-map stuff needs to apply our own translate
         (love.graphics.translate state.tx state.ty)
         (when state.laser
           (draw-laser state.laser))
         (love.graphics.pop))
 ;; these layer draw functions get called by the tiled library at the right time
 ;; so other layers can obscure them when necessary
 :draw-player (fn [world state]
                (each [_ rover-num (ipairs state.probe.rovers)]
                  (draw-rover (. state.rovers rover-num) world state))
                (draw-probe world state.probe (= state.probe state.selected)))
 ;; Ideally we could just let the tiled lib draw this, but there seems to be
 ;; no way to change an object's sprite at runtime?
 :draw-sensors (fn [layer]
                 (each [_ sensor (ipairs layer.objects)]
                   (love.graphics.draw (if sensor.properties.on
                                           sensor-on-img sensor-img)
                                       ;; TODO: why is the y wrong?
                                       sensor.x (- sensor.y sensor.height))))
 :draw-doors (fn [layer]
               (each [_ door (ipairs layer.objects)]
                 (love.graphics.draw (if door.properties.open
                                         door-open-img door-img)
                                     door.x (- door.y door.height))))
 :draw-terms (fn [layer]
               (each [_ term (ipairs layer.objects)]
                 (: term-anim :draw term-img term.x (- term.y term.height))))
 :update (fn [dt]
           (: term-anim :update dt))}
