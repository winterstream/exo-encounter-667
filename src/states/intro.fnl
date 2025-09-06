(local lume (require :lib.lume))

(local splash-screen-system (require :src.systems.splash-screen-system))

(local messages
       (icollect [i text (ipairs (lume.split (love.filesystem.read :text/splash)
                                             "\n"))]
         {: text :x 8 :y (+ (* 18 i) 110) :time (* i 2)}))

(local splash (splash-screen-system messages))

(var counter 0)

{:draw #(splash:update)
 :update (fn [dt set-mode]
           (set counter (+ counter dt))
           (set splash.counter counter)
           (when (> counter 16)
             (set-mode :main)))
 :keypressed (fn [key set-mode]
               (if (= key :space)
                   (set counter
                        (if (> counter 8)
                            (set-mode :main)
                            (* 2 (math.ceil (/ counter 2)))))
                   (set-mode :main)))}
