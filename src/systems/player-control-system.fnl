(local class (require :lib.30log))

(local const (require :const))

(local player-control-system (class :player-control-system))

(fn player-control-system.init [self state]
  (set self.state state))

(fn compute-velocity [s dt]
  (let [l? (love.keyboard.isDown :left)
        r? (love.keyboard.isDown :right)
        u? (love.keyboard.isDown :up)
        d? (love.keyboard.isDown :down)
        scale-speed (if (love.keyboard.isDown :lshift :rshift) 0.2 1)]
    (if (= s.type :rover)
        (do
          (when (or l? r?)
            (set s.theta (+ s.theta
                            (* 2 (if r? scale-speed (- scale-speed))
                               const.turn-speed dt))))
          (when (or u? d?)
            (let [delta (if u? scale-speed (- scale-speed))]
              (set s.vx (* (math.cos s.theta) const.rover-move-speed delta))
              (set s.vy (* (math.sin s.theta) const.rover-move-speed delta)))))
        (= s.type :probe)
        (do
          (set s.stuck? (and (or l? r? u? d?) (not s.mobile?)))
          (when (not s.stuck?)
            (let [speed (if (love.keyboard.isDown "=") 164
                            const.probe-move-speed)
                  scaled-speed (* speed scale-speed)]
              (set s.vx (+ (if l? (- scaled-speed) 0) (if r? scaled-speed 0)))
              (set s.vy (+ (if u? (- scaled-speed) 0) (if d? scaled-speed 0)))))))))

(fn player-control-system.update [self dt]
  (set self.state.probe.stuck? false)
  (let [s self.state.selected]
    (when (and s (not s.immobilized?))
      (compute-velocity s dt))))

player-control-system
