(local songs {:temple (love.audio.newSource "assets/GalacticTemple.ogg"
                                            "stream")})

(var current songs.temple)

(defn toggle []
  (if (love.filesystem.getInfo "mute")
      (do (love.filesystem.remove "mute")
          (: current :play))
      (do (love.filesystem.write "mute" "true")
          (: current :stop))))

(defn choose [name]
  (when (and (not (= current (. songs name))) (: current :isPlaying))
    (: current :stop))
  (set current (. songs name))
  (: current :setLooping true)
  (: current :play))

{:toggle toggle
 :choose choose}
