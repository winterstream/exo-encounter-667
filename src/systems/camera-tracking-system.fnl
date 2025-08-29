(local class (require :lib.30log))
(local lume (require :lib.lume))

(local const (require :const))

(local camera-tracking-system (class :camera-tracking-system))

(fn camera-tracking-system.init [self state]
  (set self.state state))

(fn camera-tracking-system.update [self dt]
  (let [state self.state
        (x y) (state.world:getRect state.selected)
        dist (lume.distance x y (+ state.tx 180) (+ state.ty 112))
        ;; scroll faster when the selected unit is offscreen, unless intro
        delta (if (and (> dist 200) state.intro-complete?)
                  (* dt const.probe-move-speed
                     (* (math.sqrt (* dist 100)) 0.02))
                  (* dt const.probe-move-speed))]
    (when (< (+ state.tx 260) x)
      (set state.tx (math.min (+ state.tx delta) 1559)))
    (when (< x (+ state.tx 80))
      (set state.tx (math.max (- state.tx delta) 0)))
    (when (< (+ state.ty 165) y)
      (set state.ty (math.min (+ state.ty delta) 1054)))
    (when (< y (+ state.ty 100))
      (set state.ty (math.max (- state.ty delta) 0)))))

camera-tracking-system
