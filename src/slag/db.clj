(ns slag.db
  (:use
   reval.core
   korma.db
   slag.utils
   korma.core
   lobos.migrations
   [lobos.connectivity :only [close-global open-global]])
  (:gen-class))

(declare global-conn-conf)

(def global-conn-established? false)

(defn get-db-conn-options
  ([dbtype options]
   (let [helper (find-var (clojure.core/symbol (str "korma.db/" dbtype)))]
     (helper options))
   )
  ([]
   (println (slag.utils/isUp?))
   (println (get (find-var 'slag.core/config) :name))
   (if (slag.utils/isUp?)
     (get-db-conn-options (get (slag.utils/lget 'slag.core/config) :name) (slag.utils/lget 'slag.core/config))))
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

(defentity users)

(def dbs
  [

   {
    :name "h2"
    :db (str (locate-user-root) "/slag")
    :make-pool? true
   }

   {
    :name "sqlite3"
    :db (str (locate-user-root) "/slag")
    :make-pool? true
   }

   {
    :name "postgres"
    :user ""
    :db "slag"
    :password ""
    :host ""
    :port ""
    :make-pool? true
   }

   {
    :name "mysql"
    :host ""
    :port ""
    :db "slag"
    :make-pool? true
   }

   {
    :name "oracle"
    :user ""
    :password ""
    :db "slag"
    :host ""
    :port ""
    :make-pool? true
   }

   {
    :name "mssql"
    :user ""
    :password ""
    :db "slag"
    :host ""
    :port ""
    :make-pool? true
   }

  ])
