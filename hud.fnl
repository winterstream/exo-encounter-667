(local lume (require "lib.lume"))
(local messages (lume.split (love.filesystem.read "text/intro") "\n"))

(var counter 0)

{:draw (fn [state]
         (love.graphics.setColor 1 1 1)
         (for [i 1 6]
           (when (. state.messages i)
             (love.graphics.print (. state.messages i) 10 (- 213 (* 18 i))))))
 :update (fn [state dt]
           (when (. messages 1)
             (set counter (+ counter dt))
             (when (> counter 1)
               (table.insert state.messages 1 (table.remove messages 1))
               (set counter 0))))}
