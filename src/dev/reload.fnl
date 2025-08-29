(local module (require (.. ... :module)))

(fn reload []
  (each [_i m (ipairs [:state :intro :play :src.dev.reload])]
    (module.reload m)))

(fn restart [set-mode]
  (reload)
  (set-mode :intro)
  nil)

{: restart : reload}
