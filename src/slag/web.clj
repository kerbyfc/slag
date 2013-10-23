(ns slag.web
  (:gen-class)
  (:use cwk.core
        reval.core
        slag.db
        slag.utils)
  (:require ring.middleware.params
            liberator.dev
            [stefon.core :as stefon]
            [cheshire.core :refer :all]
            [com.github.ragnard.hamelito.hiccup :as haml]))


(def web-api {
              :service-available? (find-ns 'slag.config)
              :available-media-types ["application/json"]
              :allowed-methods [:get :put :post]
              })

(def stefon-setup
  {
   :asset-roots ["resources/assets"]
   :serving-root "public"
   :mode :development
   :manifest-file "manifest.json"
   :precompiles ["./assets/app.js.stefon"]
   })

(defn html
  [temp]
  (haml/html temp))

(defn alink
  [asset]
  (stefon/link-to-asset asset stefon-setup))

(defn usr-root
  []
  (reval.core/locate-user-root))

(defn app-root
  []
  (let [root (reval.core/locate-application-root 'slag.web)]
    (if (reval.core/jar? root)
      (reval.core/location root)
      root)))

(defn embed
  [t k v]
  (clojure.string/replace t (re-pattern (name k)) v))

(defn get-available-dbs
  []
  (generate-string slag.db/dbs))

(reval 'slag.web "api" (use 'cwk.core 'slag.web))

(def handler (wrapped-handler ->
                              ring.middleware.params/wrap-params
                              (stefon/asset-pipeline stefon-setup)
                              (liberator.dev/wrap-trace :header :ui)))

(defn start-service
  [opts]
  (cwk.core/run handler opts))
