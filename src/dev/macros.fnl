(fn do-every-n-sec [n & body]
  "Runs the code in `body` at most once every `n` seconds.

   This macro creates a unique identifier for each call site based on the
   file and line number of the first expression in its body, using Fennel's
   built-in metadata for s-expressions. It uses a global table to store the
   last time the log was triggered for that specific site, allowing each
   usage of the macro to have its own independent cooldown.

   Usage:
   (do-every-n-sec 5 (print \"This message appears at most every 5 seconds\"))"
  (let [first-item (. body 1)
        filename (or (. first-item :filename) :repl)
        line (or (. first-item :line) :unknown)
        key (.. filename ":" line)]
    `(let [state-table# (do
                          (tset _G :_log_every_n_sec_state
                                (or (. _G :_log_every_n_sec_state) {}))
                          (. _G :_log_every_n_sec_state))
           last-log-time# (. state-table# ,key)
           current-time# (os.time)]
       (when (or (not last-log-time#) (>= (- current-time# last-log-time#) ,n))
         (tset state-table# ,key current-time#)
         (unpack ,body)))))

{: do-every-n-sec}
