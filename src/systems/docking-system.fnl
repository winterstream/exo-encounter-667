(local beholder (require :lib.beholder))
(local class (require :lib.30log))
(local lume (require :lib.lume))

(local docking-system (class :docking-system))

(fn within? [state box margin]
  (let [(x y width height) (state.world:getRect state.selected)]
    (and (< (- box.x margin) x (+ x width) (+ box.x box.width margin))
         (< (- box.y margin) y (+ y height) (+ box.y box.height margin)))))

;; can't move unless 3 or 4 rovers are docked
(fn enough-docked? [state]
  (< 2 (length (lume.filter state.rovers :docked?))))

;; TODO: these are bad
(local offsets [[-10 -10] [20 -10] [20 20] [-10 20]])

(fn deploy [state n]
  (tset (. state.rovers n) :docked? false)
  (set state.probe.mobile? (enough-docked? state))
  (let [[ox oy] (. offsets n)
        (px py) (state.world:getRect state.probe)]
    (state.world:add (. state.rovers n) (+ px ox) (+ py oy) 10 10)))

(fn dock [state]
  (let [(x y w h) (state.world:getRect state.probe)]
    (when (and (= state.selected.type :rover)
               (within? state {: x : y :width w :height h} 12))
      (set state.selected.docked? true)
      (set state.probe.mobile? (enough-docked? state))
      (state.world:remove state.selected)
      (set state.selected state.probe))))

(fn select [state n]
  (when n (beholder.trigger :enable-autopilot false))
  (set state.selected (if n
                          (. state.rovers n)
                          state.probe))
  (when (and n (not (state.world:hasItem (. state.rovers n))))
    (deploy state n)))

(fn no-action [])

(fn docking-system.init [self state]
  (beholder.observe :keypressed
                    (fn [key]
                      (if (and (>= key :1) (<= key :4))
                          (set self.action #(select $ (tonumber key)))
                          (or (= key :0) (= key :5) (= key "`"))
                          (set self.action select)
                          (= key :return)
                          (set self.action dock))))
  (set self.state state)
  (set self.action no-action))

(fn docking-system.update [self]
  (self.action self.state)
  (set self.action no-action))

docking-system
