(local lume (require "lib.lume"))
(local intro-msgs (lume.split (love.filesystem.read "text/intro") "\n"))

(defn step [state flag check]
  (while (not (or (check state) (. state.flags flag)))
    (coroutine.yield))
  ;; save our progress so we can restart or reload this module
  (tset state.flags flag true))

(defn sensor? [map name]
  (let [sensor (lume.match map.layers.sensors.objects
                           (fn [s] (= s.name name)))]
    (and sensor sensor.properties.on)))

(var counter 0)

(fn echo-intro [state _world _map dt]
  (when (. intro-msgs 1)
    (set counter (+ counter dt))
    (when (> counter 0.5)
      (: state :echo (table.remove intro-msgs 1))
      (set counter 0))
    (echo-intro (coroutine.yield))))

(defn tutorial [state world map dt]
  (echo-intro state world map dt)
  (: state :echo "Press 2 to select rover 2; bring it near")
  (: state :echo "main probe and press enter to dock.")
  (step state :first-dock (fn [] (. state.rovers 2 :docked?)))
  (: state :echo "")
  (: state :echo "With at least 3 rovers docked, the main")
  (: state :echo "probe has mobility.")
  (: state :echo "")
  (: state :echo "Now do the same with rover 3.")
  (step state :second-dock (fn [] (. state.rovers 3 :docked?)))
  (: state :echo "")
  (: state :echo "")
  (: state :echo "The probe's communications laser can be")
  (: state :echo "activated by holding space. Comma and")
  (: state :echo "period change the aim of the laser.")
  (step state :laser (fn [] (or state.laser
                                (> (: world :getRect state.selected) 730)
                                (sensor? map "first"))))
  (: state :echo "")
  (: state :echo "")
  (: state :echo "")
  (: state :echo "SENSORS: detected nearby structure to")
  (: state :echo "the north which may react to the laser.")
  (step state :first-sensor (fn [] (or (> (: world :getRect state.selected) 730)
                                       (sensor? map "first"))))
  (: state :echo "")
  (: state :echo "")
  (: state :echo "")
  (: state :echo "MISSION: proceed thru the door and")
  (: state :echo "investigate signs of civilization.")
  (step state :gap (fn [] (> (: world :getRect state.selected) 730)))
  (: state :echo "")
  (: state :echo "")
  (: state :echo "")
  (: state :echo "DEPLOY: press 2 to deploy a rover to")
  (: state :echo "investigate the gap in the north wall.")
  (step state :gap2 (fn []
                      (let [(x y) (: world :getRect state.selected)]
                        (and (> x 720) (< y 1050)))))
  (: state :echo "")
  (: state :echo "")
  (: state :echo "")
  (: state :echo "REFLECT: aim the laser at the rover to")
  (: state :echo "target the obscured sensor.")
  (step state :second-sensor (fn [] (or (> (: world :getRect state.selected)
                                           1230) (sensor? map "second"))))
  (: state :echo "")
  (: state :echo "")
  (: state :echo "")
  (: state :echo "")
  (: state :echo "Continue exploration and collect clues.")
  (step state :second-sensor (fn [] (sensor? map "third")))
  (: state :echo "")
  (: state :echo "")
  (: state :echo "")
  (: state :echo "")
  (: state :echo "")
  (while (coroutine.yield) (coroutine.yield)))

{:update (coroutine.wrap tutorial)}
