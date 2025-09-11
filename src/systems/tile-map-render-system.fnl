(local class (require :lib.30log))

(local tile-map-render-system (class :tile-map-render-system))

(fn tile-map-render-system.init [self state]
  (set self.state state))

(fn tile-map-render-system.update [self dt]
  (self.state.map:update dt)
  (self.state.map:draw (- self.state.tx) (- self.state.ty)))

tile-map-render-system
