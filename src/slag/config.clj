(ns slag.config)
(in-ns 'slag.core)

(declare global-conn-conf)

(def global-conn-established? false)

(defn get-db-conn-options
  ([dbtype options]
   (let [helper (find-var (clojure.core/symbol (str "korma.db/" dbtype)))]
     (helper options))
   )
  ([]
   (println (isUp?))
   (println (get (find-var 'conf) :name))
   (if (isUp?)
     (get-db-conn-options (get (lget 'conf) :name) (lget 'conf))))
  )

(defn open-global-connection
  ([conf]
   (if (not (and (= global-conn-conf conf) global-conn-established?))
     (do
       (def global-conn-conf conf)
       (if global-conn-established?
         (close-global))
       (open-global conf)
       (defdb db conf) ; TODO check@!
       (def global-conn-established? true)
       )
     )
   (if global-conn-established?
     (lobos.core/migrate)))
  ([]
   (open-global-connection (get-db-conn-options))
   ))
