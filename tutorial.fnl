(local intro-msgs (lume.split (love.filesystem.read :text/intro) "\n"))

(fn step [state _ check]
  (while (not (check state))
    (coroutine.yield)))

(fn sensor? [map name]
  (let [sensor (lume.match map.layers.sensors.objects
                           (fn eq [s] (= s.name name)))]
    (and sensor sensor.properties.on)))

(var counter 0)

(fn echo [state ...]
  (let [msgs [...]]
    (while (< (length msgs) 5)
      (table.insert msgs 1 ""))
    (lume.map msgs (fn mapper [m] (: state :echo m)))))

(fn echo-intro [state _world _map dt]
  (when (. intro-msgs 1)
    (set counter (+ counter dt))
    (when (> counter 0.5)
      (: state :echo (table.remove intro-msgs 1))
      (set counter 0))
    (echo-intro (coroutine.yield))))

(fn tutorial [state world map dt]
  (echo-intro state world map dt)
  (set state.intro-complete? true) ; we can scroll quickly now
  (echo state "Press 2 to select rover 2; bring it near"
        "the main probe and press enter to dock.")
  (step state :first-dock (fn d2 [] (. state.rovers 2 :docked?)))
  (echo state "With at least 3 rovers docked, the main" "probe has mobility."
        "" "Now do the same with rover 3.")
  (step state :second-dock (fn d3 [] (. state.rovers 3 :docked?)))
  (echo state "The probe's communications laser can be"
        "activated by holding space. Comma and"
        "period change the aim of the laser.")
  (step state :laser (fn laser? []
                       (or (and state.laser (not= state.selected.theta math.pi))
                           (sensor? map :first) (sensor? map :second)
                           (sensor? map :third))))
  (echo state "SENSORS: detected nearby structure to"
        "the north of the crash site which may" "react to the laser.")
  (step state :first-sensor
        (fn s1 []
          (or (sensor? map :first) (sensor? map :second) (sensor? map :third))))
  (echo state "MISSION: proceed thru the door and"
        "investigate signs of civilization.")
  (step state :gap
        (fn gapper []
          (or (> (: world :getRect state.selected) 730) (sensor? map :second)
              (sensor? map :third))))
  (echo state "DEPLOY: press 2 to deploy a rover to"
        "investigate the gap in the north wall.")
  (step state :gap2 (fn gapper2 []
                      (let [(x y) (: world :getRect state.selected)]
                        (or (and (> x 720) (< y 1050)) (sensor? map :second)
                            (sensor? map :third)))))
  (echo state "REFLECT: aim the laser at the rover to"
        "target the obscured sensor.")
  (step state :second-sensor
        (fn s2 []
          (or (> (: world :getRect state.selected) 1230) (sensor? map :second))))
  (echo state "Pressing backspace will recall rovers."
        "Continue exploration and collect clues.")
  (step state :third-sensor (fn s3 [] (sensor? map :third)))
  (echo state)
  (while (coroutine.yield) (coroutine.yield)))

{:update (coroutine.wrap tutorial)}
