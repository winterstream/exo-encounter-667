(local font (love.graphics.newFont "assets/FSEX300.ttf" 16))

(defn draw-rover [i rover world state]
  (if (= rover state.selected)
      (love.graphics.setColor 0.5 0.5 0.5)
      (love.graphics.setColor 0.2 0.2 0.2))
  ;; x and y for rovers are the upper left corners
  (let [(x y w h) (: world :getRect rover)
        radius (/ w 2)
        x1 (+ x radius)
        y1 (+ y radius)
        x2 (+ x1 (* (math.cos rover.theta) radius))
        y2 (+ y1 (* (math.sin rover.theta) radius))]
    (love.graphics.circle "fill" (+ x radius) (+ y radius) radius)
    (love.graphics.setColor 0.1 0.1 0.1)
    (love.graphics.line x1 y1 x2 y2)))

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
 :draw-player (fn [world state self]
                (each [i rover (ipairs state.rovers)]
                  (draw-rover i rover world state))
                (draw-probe world state.probe (= state.probe state.selected)))}
