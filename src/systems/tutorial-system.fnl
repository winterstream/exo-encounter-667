(local class (require :lib.30log))
(local tutorial (require :tutorial))

(local tutorial-system (class :tutorial-system))

(fn tutorial-system.init [self state]
  (set self.state state))

(fn tutorial-system.update [self dt]
  (tutorial.update self.state self.state.world self.state.map dt))

tutorial-system
