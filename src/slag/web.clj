(ns slag.web
  (:gen-class)
  (:use cwk.core
        reval.core)
  (:require ring.middleware.params
            liberator.dev
            [stefon.core :as stefon]
            [com.github.ragnard.hamelito.hiccup :as haml]))

(def web-api-conf {
              :service-available? (find-ns 'slag.config)
              :available-media-types ["text/plain"]
              :allowed-methods [:get :put :post]
              })

(def stefon-conf
  {
   ;; Searched for assets in the order listed. Must have a directory called 'assets'.
   :asset-roots ["resources/assets"]

   ;; The root for compiled assets, which are written to (serving-root)/assets. In dev mode defaults to "/tmp/stefon")
   :serving-root "public"

   ;; Set to :production to serve precompiled files, or when running `lein stefon-precompile`
   :mode :development

   ;; Where the result of the precompile should be stored. Might be good to keep it out of the web root.
   :manifest-file "manifest.json"

   ;; When precompiling, the list of files to precompile. Can take regexes (coming soon), which will attempt to match all files in the asset roots.
   :precompiles ["./assets/app.js.stefon"]

   })

(defn embed-assets
  [template assets-type]
  (clojure.string/replace template (re-pattern (str "_" assets-type "_")) (stefon/link-to-asset (str assets-type "/app." assets-type ".stefon") stefon-conf)))

(def template
  (-> (haml/html (slurp (clojure.java.io/resource "home.haml")))
      (embed-assets "css")
      (embed-assets "js")))

template


(reval 'slag.resources "controllers" (use 'cwk.core 'slag.web))

(def handler (wrapped-handler ->
                              ring.middleware.params/wrap-params
                              (stefon/asset-pipeline stefon-conf)
                              (liberator.dev/wrap-trace :header :ui)))
