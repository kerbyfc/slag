(ns slag.db
  (:use
   reval.core
   korma.db
   korma.core
   [lobos.connectivity :exclude [default-connection]]
   [lobos.core :only [migrate]])
  (:gen-class))

(declare global-conn-conf)

(def global-conn-established? false)

(defn get-full-db-conn-options
  [dbtype options]
  (let [helper (find-var (clojure.core/symbol (str "korma.db/" dbtype)))]
    (helper options)))

(defn open-global-connection
  [conf]
  (if (not (and (= global-conn-conf conf) global-conn-established?))
    (do
      (def global-conn-conf conf)
      (if global-conn-established?
        (close-global))
      (open-global conf)
      (def global-conn-established? true)
      )
    ))

(defn do-migrations
  []
  (migrate))

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
