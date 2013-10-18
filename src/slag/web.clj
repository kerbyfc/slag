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

(map? (merge {} {:sd true}))

(defn fname [f]
  (subs (first (re-find #"(\$)[A-Za-z0-9]*" (.toString f))) 1))

(defn ensure-argument
  [priority checker given & expected]
  (let [priors ["first" "second" "third" "forth" "fifth" "sixth"]]
    (if (not (checker given))
      (throw (IllegalArgumentException. (str "Please, pass " (or (first expected) (fname checker)) " as " (get priors priority) " argument"))))))

(defmacro defres
  [& form]
  (let [[root common route args res & nxt] (vec form)
        factory `(res-handler ~(str root route) ~args (merge ~common ~res))]
    (ensure-argument 1 string? root)
    (cond (nil? nxt) factory
          :else `(do
                   (defres ~root ~common ~@nxt)
                   ~factory))))

(defmacro =>
  [ctx & kvs]
  (let [bindings (vec (map-indexed #(if (even? %1) (vec %2) (first %2)) (partition-by #(not (symbol? %)) (remove seq? (pop (vec kvs))))))
        vars (vec (keep-indexed #(if (odd? %1) %2) bindings))
        values (vec (keep-indexed #(if (even? %1) %2) bindings))]
    (if (and (> (count values) 0) (= (count values) (count vars)))
      `(fn [$#] (apply (fn [~ctx ~@vars] ~(last kvs)) (apply conj [$#] (vec (map #(get-in $# %) ~values)))))
      `(fn [$#] (apply (fn [~ctx] ~(last kvs)) [$#]))
      )
    ))

(def common-options {
              :available-media-types ["text/plain"]
              :allowed-methods [:get :put :post]
           })

(defres "servers"

          (merge common-options {:available-media-types ["text/plain" "text/html"]})

           "/:id" [id] {
                        :handle-ok (=> r
                                     (format "SERVER WITH ID %s" id))
                        }

           "" [] {

                  :exists? (=> ctx :request :query-params "choice" c
                              (if (not (nil? (find {"1" "apple" "2" "orange"} c)))
                                {:choice c}))


                  :handle-not-found (=> r :choice c
                                     (format "<html>There is no value for the option &quot;%s&quot;"
                                             c))

                  :handle-ok (=> ctx :choice c :representation :media-type mt
                                 (condp = mt
                                   "text/html" (format "<html><a href='#'>Your choice: &quot;%s&quot;</a>." c)
                                   "text/plain" (format "Your choice: \"%s\".\n" c))
                                   )

                  :handle-not-acceptable "Uh, Oh, I cannot speak those languages!"

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







