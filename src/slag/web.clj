(ns slag.web
  (:gen-class)
	(:use slag.utils slag.loader)
  (:require ring.adapter.jetty ring.middleware.params compojure.core liberator.core liberator.dev))

(declare api handler)
(def routes (ref {}))

(defmacro res*
  "Create resource and make route for it"
  [route args & kvs]
  `(dosync
      (ref-set slag.web/routes (merge @slag.web/routes {~(keyword (clojure.string/replace route #"(/:)([\w]*)" "/$2")) (compojure.core/ANY (str "/" ~route) ~args (fn [request#] (liberator.core/run-resource request# ~@kvs)))}))))

(defmacro resource*
  [& form]
  (let [[root common route args res & nxt] (vec form)
        factory `(res* ~(str root route) ~args ~(merge common res))]
    (cond (nil? nxt) factory
          :else `(do
                   (resource* ~root ~common ~@nxt)
                   ~factory))))


(reval 'slag.resources "api" (use 'slag.web 'slag.helpers))

(def api (apply compojure.core/routes 'api (vals @routes)))

(def handler (-> api
                 ring.middleware.params/wrap-params
                 (liberator.dev/wrap-trace :header :ui)))

(defn start-service
 [port]
  (ring.adapter.jetty/run-jetty handler {:port port :join? false}))







