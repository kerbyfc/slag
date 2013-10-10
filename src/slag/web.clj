(ns slag.web
	(:use
   [ring.adapter.jetty :only [run-jetty]]
   [slag.utils])
  (:require
   [compojure.route :refer  [not-found]]
   [compojure.core  :refer  [defroutes ANY]]
   [liberator.core  :refer  [resource run-resource defresource]]
   [slag.web.resources n404]
   [liberator.dev   :refer  [wrap-trace]]))

(declare api handler)
(def routes (ref []))

(defmacro defres
  "Create resource and make route for it"
  [name & kvs]
  `(dosync
    (defresource ~name ~@kvs)
    (ref-set routes (conj @routes (ANY (str "/" '~name) [] ~name)))))

(defres tst
  :available-media-types ["text/html"]
  :handle-ok "yo!")

(defres lol2
  :available-media-types ["text/html"]
  :handle-ok "yo!")

(defres lol3
  :available-media-types ["text/html"]
  :handle-ok "dfdyo3dddd!")

(def api (apply compojure.core/routes 'api (conj @routes (not-found "404"))))
(def handler (-> api (wrap-trace :header :ui)))




