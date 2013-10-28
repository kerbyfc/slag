(ns slag.core

  (:gen-class)

  (:refer-clojure)

  (:use

   [cheshire.core :rename {
             generate-string to-json
             parse-stream parse-json-stream
             parse-string parse-json
             }]

   [clojure.string :as cstr
    :only [split
           lower-case
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
    migrations
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
(load "database")
(load "init")
(load "web")

(init)

(to-json {:error setup-error})
(to-json config)

(def handler (wrapped-handler ->
                              ring.middleware.params/wrap-params
                              (stefon/asset-pipeline stefon-setup)
                              (liberator.dev/wrap-trace :header :ui)))

(defn -main
  "Run web service"
  [& args]
    (cwk.core/run handler {:port 8000})
  )


