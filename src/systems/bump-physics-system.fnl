(local class (require :lib.30log))

(local bump-physics-system (class :bump-physics-system))

(fn bump-physics-system.init [self state]
  (set self.state state))

(fn collide-filter [_item other]
  (if (or (love.keyboard.isDown :backspace) ; noclip
          (and other.properties other.properties.terminal))
      :cross
      :slide))

(fn within? [world item box margin]
  (let [(x y width height) (world:getRect item)]
    (and (< (- box.x margin) x (+ x width) (+ box.x box.width margin))
         (< (- box.y margin) y (+ y height) (+ box.y box.height margin)))))

(fn process-undocked [state e dt set-mode]
  (let [(x y) (state.world:getRect e)
        new-x (+ x (* e.vx dt))
        new-y (+ y (* e.vy dt))
        (_ _ cols) (state.world:move e new-x new-y collide-filter)]
    (when (= e state.selected) ; (assert-repl false)
      (set e.in-term? false)
      (each [_ col (ipairs cols)]
        (when (and col.other.properties col.other.properties.terminal
                   (within? state.world col.item col.other
                     0))
          (set e.in-term? true)
          (when (not e.in-term-last-tick?)
            (set-mode :term col.other.properties.terminal)))))))

(fn bump-physics-system.update [self dt set-mode]
  (let [entities [self.state.probe (unpack self.state.rovers)]]
    (each [_ e (ipairs entities)]
      (when (not e.docked?)
        (process-undocked self.state e dt set-mode))
      (set e.vx 0)
      (set e.vy 0)))
  (set self.state.selected.in-term-last-tick? self.state.selected.in-term?))

bump-physics-system
