(ns slag.web
  (:gen-class)
  (:use cwk.core
        reval.core)
  (:require ring.middleware.params
            liberator.dev))

(def options {
              :available-media-types ["text/plain"]
              :allowed-methods [:get :put :post]
              })

(reval 'slag.resources "api" (use 'cwk.core 'slag.web))

(def handler (wrapped-handler ->
                ring.middleware.params/wrap-params
                (liberator.dev/wrap-trace :header :ui)))
