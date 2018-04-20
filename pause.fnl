(let [intro (require :intro)]
  {:draw (partial intro.draw "press any key")
   :update (fn [])
   :keypressed (fn [_ set-mode] (set-mode :play))})
