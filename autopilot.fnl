(var on? false)

(fn update [state world dt rover-forward]
  (when on?
    (let [(px py) (: world :getRect state.probe)]
      (for [i 1 4]
        (when (not (. (. state.rovers i) :docked?))
          (let [r (. state.rovers i)
                (x y) (: world :getRect r)]
            (when (> (lume.distance (+ px 7) (+ py 10) x y) 32)
              (set r.theta (math.atan2 (- py y) (- px x)))
              (rover-forward r dt))))))))

{:update update
 :enable (fn [] (set on? true))
 :disable (fn [] (set on? false))}
