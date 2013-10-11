(ns slag.web
  (:gen-class)
	(:use
   [ring.adapter.jetty :only [run-jetty]]
   [slag.utils])
  (:require
   [compojure.route :refer  [not-found]]
   [compojure.core  :refer  [ANY]]
   [liberator.core  :refer  [defresource]]
   [liberator.dev   :refer  [wrap-trace]]))

(declare api handler)
(def routes (ref {}))

(defmacro defres
  "Create resource and make route for it"
  [name & kvs]
  `(dosync
    (defresource ~name ~@kvs)
    (ref-set slag.web/routes (merge @slag.web/routes { ~(keyword name) (ANY (str "/" ~name) [] ~name) } ))))

(macroexpand '(defres parsers
             :available-media-types ["text/html"]
             :handle-ok "PARSERS"))

(slag.utils/include "resources")

(defres parsers
  :available-media-types ["text/html"]
  :handle-ok "PARSERSsdf")

@routes

(def api (apply compojure.core/routes 'api (vals @routes)))
(def handler (-> api (wrap-trace :header :ui)))

(run-jetty handler {:port 8001 :join? false})
