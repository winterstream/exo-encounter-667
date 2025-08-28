(var last-traceback "")

(set package.preload.fennel (require :lib.fennel))
(set package.loaded.fennel (require :lib.fennel))

(fn try-call [f]
  (let [(success result) (xpcall f debug.traceback)]
    (when (not success)
      (if (not= result last-traceback)
          (do
            (print result)
            (set last-traceback result))))))

{: try-call}
