(local songs {:temple (love.audio.newSource "assets/GalacticTemple.ogg"
                                            "stream")
              :pressure (love.audio.newSource "assets/Pressure.ogg"
                                              "stream")})

(var current songs.temple)

(defn toggle []
  (if (love.filesystem.getInfo "mute")
      (do (love.filesystem.remove "mute")
          (: current :play))
      (do (love.filesystem.write "mute" "true")
          (: current :stop))))

(defn choose [name]
  (: current :stop)
  (set current (. songs name))
  (: current :setLooping true)
  (when (not (love.filesystem.getInfo "mute"))
    (: current :play)))

{:toggle toggle
 :choose choose}
