(local font (love.graphics.newFont "assets/FSEX300.ttf" 16))

(defn draw-rover [i rover state]
  (if (= rover state.selected)
      (love.graphics.setColor 0.5 0.5 0.5)
      (love.graphics.setColor 0.2 0.2 0.2))
  (let [radius (/ rover.width 2)]
    (love.graphics.circle "fill" (+ rover.x radius) (+ rover.y radius)
                          rover.width)
    (love.graphics.setColor 0.1 0.1 0.1)
    (let [x1 (+ rover.x radius)
          y1 (+ rover.y radius)
          x2 (+ x1 (* (math.cos rover.r) radius))
          y2 (+ y1 (* (math.sin rover.r) radius))]
      (love.graphics.line x1 y1 x2 y2))))

;; (defn draw-probe [probe])

{:draw (fn [map state]
         (: map :draw state.tx state.ty))
 :draw-player (fn [state self]
                (each [i rover (ipairs self.sprites)]
                  (draw-rover i rover state))
                ;; (draw-probe (. self.sprites 0))
                )}
