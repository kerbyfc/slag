(ns lobos.config
  (:use lobos.connectivity))

(def db
  {:classname "org.h2.Driver"
   :subprotocol "h2"
   :subname "/Users/kerbyfc/TEST.db"})

(open-global db)
