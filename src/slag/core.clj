(ns slag.core

  (:gen-class)

  (:use

   [cheshire.core :as ch
    :only [generate-string
           parse-stream
           parse-string]]

   [clojure.string :as cstr
    :only [split
           trim]
    :rename {replace str-replace
             join str-join}]

   [reval.core :as re
    :only [reval
           locate-user-root
           locate-application-root
           location
           jar?]]

   (korma db core)

   (lobos
    [connectivity
     :only [open-global close-global]]
    [core
     :only [migrate]])

   [cwk.core :as cwk
    :only [defres
           defresources
           wrapped-handler
           run
           =>]]

   [stefon.core :as stefon
    :only [
           link-to-asset
           asset-pipeline]]

   [com.github.ragnard.hamelito.hiccup :as haml
    :only [html]]

   [liberator.dev :as libd
    :only [wrap-trace]]

   [ring.middleware.params :as rparams
    :only [wrap-params]]

   ))

(load "utils")
(load "lobos")
(load "database")
(load "web")
(load "init")

(defn -main
  "Run web service"
  [& args]
  (hi)
  ;(start-service {:port 8000})
  )


