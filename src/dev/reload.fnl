(local module (require (.. ... :module)))

(fn reload []
  (each [_i m (ipairs [:intro :play :src.dev.reload])]
    (module.reload m)))

(fn restart [set-mode]
  (reload)
  (set-mode :intro)
  nil)

{: restart : reload}
