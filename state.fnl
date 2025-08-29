(local bump (require :lib.bump))
(local lint (require :lint))
(local tiled (require :lib.tiled))

(local map (lint (tiled :map.lua [:bump])))
(local world (bump.newWorld))

(local rovers [{:theta 0 :docked? true :type :rover}
               {:theta 3 :docked? false :type :rover}
               {:theta 2 :docked? false :type :rover}
               {:theta 0 :docked? true :type :rover}])

(local probe {:theta math.pi :type :probe :rovers []})

(map:bump_init world)
(world:add probe 105 1205 30 24)
(world:add (. rovers 2) 165 1200 10 10)

; start undocked
(world:add (. rovers 3) 145 1212 10 10)

{:tx 200
 :ty 500
 : rovers
 : probe
 :selected nil
 :laser nil
 :flags {}
 ; for tutorial progression
 :messages []
 ; for hud
 ;; for repl debugging
 : map
 : world
 :echo (fn [s msg] (table.insert s.messages 1 msg))}
