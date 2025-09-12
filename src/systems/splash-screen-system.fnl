(local class (require :lib.30log))
(local assets (require :src.assets))
(local splash-screen-system (class :splash-screen-system))

(fn splash-screen-system.init [self text]
  (set self.text text)
  (set self.counter 0))

(fn splash-screen-system.update [self]
  (love.graphics.setFont assets.intro-font)
  (love.graphics.draw assets.intro-img)
  (love.graphics.print "EXO_encounter 667" 32 16)
  (love.graphics.setFont assets.small-font)
  (each [_ {: text : x : y : time} (ipairs self.text)]
    (when (or (not time) (> self.counter time))
      (love.graphics.print text x y))))

splash-screen-system
