(local splash-screen-system (require :src.systems.splash-screen-system))

(local help [{:x 16 :y 62 :text (love.filesystem.read :text/help)}])

(local splash (splash-screen-system help))

{:draw #(splash:update)
 :keypressed (fn [key set-mode]
               (if (= key :q)
                   (love.event.quit)
                   (set-mode :main)))}
