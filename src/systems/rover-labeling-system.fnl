(local class (require :lib.30log))

(local assets (require :src.assets))

(local rover-labeling-system (class :rover-labeling-system))

(fn rover-labeling-system.init [self state]
  (set self.state state))

(fn label-rover [world rover number selected?]
  (when (and (not selected?) (not rover.docked?))
    (let [(x y) (world:getRect rover)]
      (love.graphics.print number (+ x 2) (- y 2)))))

(fn rover-labeling-system.update [self]
  (love.graphics.push)
  ;; drawing non-map stuff needs to apply our own translate
  (love.graphics.translate (- self.state.tx) (- self.state.ty))
  (love.graphics.setColor 1 1 1)
  (love.graphics.setFont assets.small-font)
  (each [i rover (ipairs self.state.rovers)]
    (label-rover self.state.world rover i (= rover self.state.selected)))
  (love.graphics.pop))

rover-labeling-system
