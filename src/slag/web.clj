(ns slag.web
  (:gen-class)
	(:use slag.utils slag.loader)
  (:require ring.adapter.jetty ring.middleware.params compojure.core liberator.core liberator.dev))

(declare api handler)
(def routes (ref {}))

(defmacro res-handler
  "Create resource and make route for it"
  [route args & kvs]
  `(dosync
      (ref-set slag.web/routes (merge @slag.web/routes {~(keyword (clojure.string/replace route #"(/:)([\w]*)" "/$2")) (compojure.core/ANY (str "/" ~route) ~args (fn [request#] (liberator.core/run-resource request# ~@kvs)))}))))

(defmacro defres
  [& form]
  (let [[root common route args res & nxt] (vec form)
        factory `(res-handler ~(str root route) ~args ~(merge common res))]
    (cond (nil? nxt) factory
          :else `(do
                   (defres ~root ~common ~@nxt)
                   ~factory))))

(defmacro =>
  [req & kvs]
  (let [bindings (vec (map-indexed #(if (even? %1) (vec %2) (first %2)) (partition-by #(not (symbol? %)) (remove seq? (pop (vec kvs))))))
        vars (vec (keep-indexed #(if (odd? %1) %2) bindings))
        values (vec (keep-indexed #(if (even? %1) %2) bindings))]
    (if (and (> (count values) 0) (= (count values) (count vars)))
      `(fn [{$# :request}]
         (apply (fn [~req ~@vars] ~(last kvs)) (apply conj [$#] (vec (map #(get-in $# %) ~values)))))
      `(fn [{$# :request}] (apply (fn [~req] ~(last kvs)) [$#]))
      )
    ))

(defres "servers"

           {
            :available-media-types ["text/plain"]
            :allowed-methods [:get :put :post]
            }


           "/:id" [id] {
                        :handle-ok (=> r
                                     (format "SERVER WITH ID %s" id))
                        }

           "" [] {

                  :exists? (=> r :query-params "a" a
                             (= "asd" a))

                  :handle-ok (str "SERVERS LIST")
                  }

           )

;(reval 'slag.resources "api" (use 'slag.web 'slag.helpers))

(def api (apply compojure.core/routes 'api (vals @routes)))

(def handler (-> api
                 ring.middleware.params/wrap-params
                 (liberator.dev/wrap-trace :header :ui)))

(defn start-service
 [port]
  (ring.adapter.jetty/run-jetty handler {:port port :join? false}))







