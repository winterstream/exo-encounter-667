(local sfxr (require :lib.sfxr))

(fn make [x]
  (let [sound (sfxr.newSound)]
    (: sound :randomize x)
    (love.audio.newSource (: sound :generateSoundData))))

(local sounds {:temple (love.audio.newSource :assets/GalacticTemple.ogg :stream)
               :pressure (love.audio.newSource :assets/Pressure.ogg :stream)
               :chirp (make 38577)
               :door (make 57560)})

(set sounds.laser
     (let [s (sfxr.newSound)]
       (: s :randomize 65505)
       (set s.envelope.decay 0.1)
       (set s.envelope.punch 0.1)
       (set s.volume.master 0.05)
       (love.audio.newSource (: s :generateSoundData))))

(: sounds.laser :setLooping true)
(: sounds.door :setLooping true)
(: sounds.temple :setLooping true)

{:toggle (fn toggle [name]
           (if (love.filesystem.getInfo :mute)
               (do
                 (love.filesystem.remove :mute)
                 (: (. sounds (or name :temple)) :play))
               (do
                 (love.filesystem.write :mute :true)
                 (each [_ sound (pairs sounds)]
                   (: sound :pause)))))
 :play (fn play [name]
         (when (and (not (: (. sounds name) :isPlaying))
                    (not (love.filesystem.getInfo :mute)))
           (: (. sounds name) :play)))
 :stop (fn stop [name] (: (. sounds name) :stop))}
