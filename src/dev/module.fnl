(local compiler (require :fennel.compiler))
(local specials (require :fennel.specials))

(fn default-on-values [xs]
  (io.write (table.concat xs "\t"))
  (io.write "\n"))

;; fnlfmt: skip
(fn default-on-error [errtype err]
  (io.write
   (case errtype
     "Runtime" (.. (compiler.traceback (tostring err) 4) "\n")
     _ (: "%s error: %s\n" :format errtype (tostring err)))))

(fn reload-low-level [module-name env on-values on-error]
  ;; Sandbox the reload inside the limited environment, if present.
  (case (pcall (specials.load-code "return require(...)" env) module-name)
    (true old) (let [old-macro-module (. specials.macro-loaded module-name)
                     _ (tset specials.macro-loaded module-name nil)
                     _ (tset package.loaded module-name nil)
                     new (case (pcall require module-name)
                           (true new) new
                           (_ msg) (do
                                     ; keep the old module if reload failed
                                     (on-error :Repl msg)
                                     (tset specials.macro-loaded module-name
                                           old-macro-module)
                                     old))]
                 ;; if the module isn't a table then we can't make changes
                 ;; which affect already-loaded code, but if it is then we
                 ;; should splice new values into the existing table and
                 ;; remove values that are gone.
                 (when (and (= (type old) :table) (= (type new) :table))
                   (each [k v (pairs new)]
                     (tset old k v))
                   (each [k (pairs old)]
                     (when (= nil (. new k))
                       (tset old k nil)))
                   (tset package.loaded module-name old))
                 (on-values [:ok]))
    (false msg) (if (msg:match "loop or previous error loading module")
                    (do
                      (tset package.loaded module-name nil)
                      (reload-low-level module-name env on-values on-error))
                    (. specials.macro-loaded module-name)
                    (tset specials.macro-loaded module-name nil)
                    ;; only show the error if it's not found in package.loaded
                    ;; AND macro-loaded
                    (on-error :Runtime (pick-values 1 (msg:gsub "\n.*" ""))))))

(fn reload [module-name]
  (case (pcall reload-low-level module-name _G default-on-values
               default-on-error)
    (false msg) (default-on-error :Runtime msg)))

{: reload}
