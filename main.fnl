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
  (start-repl))

(defn love.draw []
  (love.graphics.print "SPAAAAAAACE" 100 100))

(defn love.keypressed [key]
  (when (= "escape" key)
    (love.event.quit)))
