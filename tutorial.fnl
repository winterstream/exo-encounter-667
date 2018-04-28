(local lume (require "lib.lume"))
(local intro-msgs (lume.split (love.filesystem.read "text/intro") "\n"))

;; (local intro-msgs [:HI]) ; TODO: delete

(defn step [state flag check msgs]
  (when (not (or (check state) (. state.flags flag)))
    (each [_ msg (ipairs msgs)]
      (: state :echo msg)))
  (while (not (or (check state) (. state.flags flag)))
    (coroutine.yield))
  ;; save our progress so we can restart or reload this module
  (tset state.flags flag true))

(var counter 0)

(fn echo-intro [state dt]
  (when (. intro-msgs 1)
    (set counter (+ counter dt))
    (when (> counter 0.5)
      (: state :echo (table.remove intro-msgs 1))
      (set counter 0))
    (echo-intro (coroutine.yield))))

(defn tutorial [state dt]
  (echo-intro state dt)
  (step state :first-dock (fn [] (. state.rovers 2 :docked?))
        ["Press 2 to select rover 2; bring it near"
         "main probe and press enter to dock."])
  ;; TODO: what if they dock rovers in the opposite order?
  (: state :echo "")
  (: state :echo "With at least 3 rovers docked, the main")
  (: state :echo "probe has mobility.")
  (: state :echo "")
  (step state :second-dock (fn [] (. state.rovers 3 :docked?))
        ["Now do the same with rover 3."])

  ;; TODO: explain laser, aiming
  ;; TODO: explain deploy
  (while (coroutine.yield) (coroutine.yield)))

{:update (coroutine.wrap tutorial)}
