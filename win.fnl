(local sound (require :sound))

(local font (love.graphics.newFont :assets/FSEX300.ttf 16))
(local bg (love.graphics.newImage :assets/win.jpg))
(local lines (lume.split (love.filesystem.read :text/win) "\n"))

(local speed -4)
(local text-speed -8)
(var counter 0)

{:draw (fn draw []
         (love.graphics.setColor 0.8 0.8 0.8)
         (love.graphics.draw bg 0 (math.floor (* counter speed)))
         (love.graphics.setColor 1 1 1)
         (for [i 1 (length lines)]
           (love.graphics.print (or (. lines i) "") 16
                                (math.floor (+ (* i 18) (* counter text-speed))))))
 :activate (fn activate []
             (love.graphics.setFont font)
             (sound.stop :laser)
             (sound.stop :temple)
             (sound.play :pressure))
 :update (fn update [dt]
           (set counter (math.min (math.max 0 (+ counter dt)) 90)))
 :keypressed (fn keypressed [key]
               (if (= key :up) (set counter (- counter 1))
                   (= key :down) (set counter (+ counter 1))
                   (= key :pageup) (set counter (- counter 20))
                   (= key :pagedown) (set counter (+ counter 20))
                   (= key :m) (sound.toggle :pressure)))}
