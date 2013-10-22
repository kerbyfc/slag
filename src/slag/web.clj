(ns slag.web
  (:gen-class)
  (:use cwk.core
        reval.core
        slag.utils)
  (:require ring.middleware.params
            liberator.dev
            [stefon.core :as stefon]
            [com.github.ragnard.hamelito.hiccup :as haml]))


(def web-api-conf {
              :service-available? (find-ns 'slag.config)
              :available-media-types ["text/plain"]
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

(defn embed-assets
  [template assets-type]
  (clojure.string/replace template (re-pattern (str "_" assets-type "_")) (stefon/link-to-asset (str assets-type "/app." assets-type ".stefon") stefon-setup)))

(def application-template
  (-> (haml/html (slurp (clojure.java.io/resource "app.haml")))
      (embed-assets "css")
      (embed-assets "js")
      (clojure.string/replace #"_up_" (str (not (nil? (find-ns 'slag.config)))))))

(reval 'slag.resources "api" (use 'cwk.core 'slag.web))

(def handler (wrapped-handler ->
                              ring.middleware.params/wrap-params
                              (stefon/asset-pipeline stefon-setup)
                              (liberator.dev/wrap-trace :header :ui)))

(defn start-service
  [opts]
  (cwk.core/run handler opts))


cwk.core/routes-map
