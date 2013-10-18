;; Slag.web builds rest api to communicate with application (web interface etc.)
;;
;; It uses:
;;
;;  - [ring](https://github.com/ring-clojure/ring) with jetty server
;;  - [compojure](https://github.com/weavejester/compojure)
;;  - [liberator](http://clojure-liberator.github.io/liberator)
;;
(ns slag.web
  (:gen-class)
  (:use slag.utils
        slag.loader)
  (:require ring.adapter.jetty
            ring.middleware.params
            compojure.core
            liberator.core
            liberator.dev))

;; stores compojure routes,
;; created by res-handler
;; to involve them in slag.web/api
(def routes (ref {}))

(defn fname
  "Returns alpha-numeric name of the function

    (fname string?)
    ; string

  "
  [f]
  (subs (first (re-find #"(\$)[A-Za-z0-9]*" (.toString f))) 1))

(defn ensure-argument
  "Throws an exception if given variable didn't passed type checks.

    (ensure-argument \"seventh\" #(string? %))
    ; nil

    (ensure-argument 1 string? non-string-arg)
    ; IllegalArgumentException Please, pass string as first argument.

    (ensure-argument 6 #(or (seq? %) (symbol? %) 123 \"sequence or symbol\")
    ; IllegalArgumentException Please, pass sequence or symbol as sixth argument.

  "
  [pos checker-function given-var & expected]
  (let [stance ["first" "second" "third" "forth" "fifth" "sixth"]]
    (if (not (checker-function given-var))
      (throw (IllegalArgumentException. (str "Please, pass " (or (first expected) (fname checker-function)) " as " (or (get stance pos) pos) " argument."))))))

(defmacro res-handler
  "Creates liberator resource, create compojure route,
  bind resource to it and merge it to routes.

    (res-handler \"/posts/:id\" [id] {
      :handle-ok \"Posts!\"})

    ; @slag.web/routes
    ; {:posts/id #<core$if_method$fn__748 compojure.core$if_method$fn__748@7f08eeac>}

  "
  [route args & kvs]
  `(dosync
    (ref-set slag.web/routes (merge
                              @slag.web/routes
                              {~(keyword (clojure.string/replace route #"(/:)([\w]*)" "/$2"))
                               (compojure.core/ANY (str "/" ~route) ~args (fn [request#] (liberator.core/run-resource request# ~@kvs)))}))))

(defmacro defres
  "Creates resources by res-handler.
  It merges common resource handlers and route with appropriate options of each resource.

    (defres \"posts\"
      {:allowed-methods [:get :put :post]}
      \"/\" [] {
        :handle-ok \"Posts\"
      }
      \"/:id\" [id] {
        :handle-ok (=> ctx
                      (str \"Post with id \" id))
      })

    ; @slag.web/routes
    ; {:posts/id #<core$if_method$fn__748 compojure.core$if_method$fn__748@24e998bb>,
    ; :posts #<core$if_method$fn__748 compojure.core$if_method$fn__748@642a2feb>}

  "
  [& form]
  (let [[root common route args res & nxt] (vec form)
        factory `(res-handler ~(str root route) ~args (merge ~common ~res))]
    (ensure-argument 1 string? root)
    (cond (nil? nxt) factory
          :else `(do
                   (defres ~root ~common ~@nxt)
                   ~factory))))

(defmacro =>
  "Creates liberator handler, binds first argument to request context and allows to create bindings to request context members.

    ...
    :handle-ok (=> ctx :representation :media-type mt :request :query-params \"name\" name
                  (str \"Greetings, \" name \". Request media-type is \" mt))

    ; curl http://......?name=Rick
    ; Greetings, Rick. Request media-type is text/plain

  "
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

(reval 'slag.resources "api" (use 'slag.web 'slag.helpers))

(def api (apply compojure.core/routes 'api (vals @routes)))

(def handler (-> api
                 ring.middleware.params/wrap-params
                 (liberator.dev/wrap-trace :header :ui)))

(defn start-service
  [port]
  (ring.adapter.jetty/run-jetty handler {:port port :join? false}))







