(ns slag.database)
(in-ns 'slag.core)

(defentity users)

(def databases-preset
  [

   {
    :name "h2"
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
    :name "sqlite3"
    :db (str (locate-user-root) "/slag")
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
