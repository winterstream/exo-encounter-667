(local lume (require "lib.lume"))

(defn find [map which]
  (lume.match map.layers.doors.objects (fn [d] (= which d.name))))

{:open (fn [map which]
         (let [door (find map which)]
           (when door
             ;; TODO: ugh we can't change collidable at runtime?!
             ;; I guess remove the closed door and replace with an open object?
             (set door.properties.collidable false))))}
