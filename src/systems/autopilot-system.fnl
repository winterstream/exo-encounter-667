(local beholder (require :lib.beholder))
(local class (require :lib.30log))
(local lume (require :lib.lume))

(local const (require :src.const))

(local autopilot-system (class :autopilot-system))

(fn autopilot-system.init [self state]
  (set self.state state)
  (set self.on? false)
  (beholder.observe :enable-autopilot #(set self.on? $))
  (beholder.observe :keypressed :backspace #(set self.on? (not self.on?))))

(fn autopilot-system.enable [self]
  (set self.on? true))

(fn autopilot-system.disable [self]
  (set self.on? false))

(fn autopilot-system.update [self]
  (when (and self.on? (= self.state.selected.type :probe))
    (let [(px py) (self.state.world:getRect self.state.probe)]
      (for [i 1 4]
        (when (not (. (. self.state.rovers i) :docked?))
          (let [r (. self.state.rovers i)
                (x y) (self.state.world:getRect r)]
            (when (> (lume.distance (+ px 7) (+ py 10) x y) 32)
              (set r.theta (math.atan2 (- py y) (- px x)))
              (set r.vx (* (math.cos r.theta) const.rover-move-speed))
              (set r.vy (* (math.sin r.theta) const.rover-move-speed)))))))))

autopilot-system
