(ns lobos.config
  (:use lobos.connectivity))

(declare db)

(defn dbconf
  [conf]
  (def db conf))
