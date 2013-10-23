(ns slag.db
  (:gen-class))

; TODO описать атрибуты чтобы динамически строить
; нормальну форму заполнения

(def dbs
  [
   {
    :name "h2"
   }

   {
    :name "postgres"
   }

   {
    :name "sqlite3"
   }

   {
    :name "mysql"
   }

   {
    :name "oracle"
   }

   {
    :name "mssql"
   }

  ])
