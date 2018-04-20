(local view (require "lib.fennelview"))
(local (w h) (values (/ 1440 2) (/ 900 2)))
(local canvas (love.graphics.newCanvas w h))

(var scale 2)
(var mode (require :intro))

(defn set-mode [mode-name]
  (set mode (require mode-name)))

(defn start-repl []
  (let [code (love.filesystem.read "stdio.fnl")
        lua (love.filesystem.newFileData (fennel.compileString code) "io")
        thread (love.thread.newThread lua)
        io-channel (love.thread.newChannel)]
    ;; this thread will send "eval" events for us to consume:
    (: thread :start "eval" io-channel)
    (set love.handlers.eval
         (fn [input]
           (let [(ok val) (pcall fennel.eval input)]
             (: io-channel :push (view val)))))))

(defn love.load []
  (: canvas :setFilter "nearest" "nearest")
  (start-repl))

(defn love.draw []
  (love.graphics.setCanvas canvas)
  (love.graphics.clear)
  (love.graphics.setColor 1 1 1)
  (mode.draw)
  (love.graphics.setCanvas)
  (love.graphics.setColor 1 1 1)
  (love.graphics.draw canvas 0 0 0 scale scale))

(defn love.update [dt]
  (mode.update dt set-mode))

(defn love.keypressed [key]
  (if (and (= key "f11") (= scale 1))
      (let [(dw dh) (love.window.getDesktopDimensions)]
        (love.window.setMode dw dh {:fullscreen true
                                    :fullscreentype :desktop})
        (set scale (/ dh 225)))

      (= key "f11")
      (do (set scale 2)
          (love.window.setMode (* w scale) (* h scale)))

      (and (love.keyboard.isDown "lctrl" "rctrl" "capslock") (= key "q"))
      (love.event.quit)

      :else
      (mode.keypressed key set-mode)))
