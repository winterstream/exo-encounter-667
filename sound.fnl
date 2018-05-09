(local sfxr (require "lib.sfxr"))

(fn make [x]
  (let [sound (sfxr.newSound)]
    (: sound :randomize x)
    (love.audio.newSource (: sound :generateSoundData))))

(local sounds
       {:temple (love.audio.newSource "assets/GalacticTemple.ogg" "stream")
        :pressure (love.audio.newSource "assets/Pressure.ogg" "stream")
        :chirp (make 38577)
        :laser (make 13599)
        :door (make 57560)})

(: sounds.laser :setLooping true)
(: sounds.door :setLooping true)
(: sounds.temple :setLooping true)

(fn toggle [name]
  (if (love.filesystem.getInfo "mute")
      (do (love.filesystem.remove "mute")
          (: (. sounds (or name :temple)) :play))
      (do (love.filesystem.write "mute" "true")
          (each [_ sound (pairs sounds)]
            (: sound :pause)))))

{:toggle toggle
 :play (fn play [name]
         (when (and (not (: (. sounds name) :isPlaying))
                    (not (love.filesystem.getInfo "mute")))
           (: (. sounds name) :play)))
 :stop (fn [name] (: (. sounds name) :stop))}
