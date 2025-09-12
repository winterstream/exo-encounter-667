

{:tx 200
 :ty 500
 :rovers []
 :probe nil
 :selected nil
 :laser nil
 :flags {}
 ; for tutorial progression
 :messages []
 ; for hud
 ;; for repl debugging
 :map nil
 :world nil
 :echo (fn [s msg] (table.insert s.messages 1 msg))}
