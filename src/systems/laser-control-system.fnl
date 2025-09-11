(local class (require :lib.30log))

(local const (require :const))
(local laser (require :laser))
(local sound (require :sound))

(local laser-control-system (class :laser-control-system))

(fn laser-control-system.init [self state]
  (set self.state state))

(fn laser-control-system.update [self dt set-mode]
  (let [p self.state.probe]
    (when (not p.immobilized?)
      (let [dt2 (if (love.keyboard.isDown :lshift :rshift) (* dt 0.2) dt)]
        (when (love.keyboard.isDown "," :w)
          (set p.theta (- p.theta (* dt2 const.turn-speed))))
        (when (love.keyboard.isDown "." :v)
          (set p.theta (+ p.theta (* dt2 const.turn-speed)))))))
  (if (love.keyboard.isDown :space :lctrl :rctrl :capslock)
      (sound.play :laser)
      (sound.stop :laser))
  (set self.state.laser
       (and (love.keyboard.isDown :space :lctrl :rctrl :capslock)
            (let [(x y w h) (self.state.world:getRect self.state.probe)]
              (laser.fire (+ x (/ w 2)) (+ y (/ h 2) -6) self.state.probe.theta
                          self.state self.state.world self.state.map []
                          [self.state.probe] 64))))
  (when (= :win self.state.laser)
    (set-mode :win)))

laser-control-system
