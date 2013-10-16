(ns slag.helpers)

(defn helper
  [x]
  (str "HELPERS sldf " x))

(defn check-existance
  [entity id]
  (println "CHECK" entity id)
  (not (nil? (get [1 2 3 4 5] id))))
