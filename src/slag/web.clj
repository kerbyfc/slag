(ns slag.web)
(in-ns 'slag.core)

(defn body-as-string [ctx]
  (if-let [body (get-in ctx [:request :body])]
    (condp instance? body
      java.lang.String body
      (slurp (clojure.java.io/reader body)))))

(defn parse-json-body [context key]
  (when (#{:put :post} (get-in context [:request :request-method]))
    (try
      (if-let [body (body-as-string context)]
        (let [data (parse-json body true)]
          [false {key data}])
        {:message "No body"})
      (catch Exception e
        (.printStackTrace e)
        {:message (format "IOException: " (.getMessage e))}))))

(defn check-content-type [ctx content-types]
  (if (#{:put :post} (get-in ctx [:request :request-method]))
    (or
     (some #{(get-in ctx [:request :headers "content-type"])}
           content-types)
     [false {:message "Unsupported Content-Type"}])
    true))

(def web-api {
              :service-available? config
              :available-media-types ["application/json"]
              :allowed-methods [:get :put :post]
              :malformed? #(parse-json-body % :data)
              :known-content-type? #(check-content-type % ["application/json"])
              })

(def stefon-setup
  {
   :asset-roots ["resources/assets"]
   :serving-root "public"
   :mode :development
   :manifest-file "manifest.json"
   :precompiles ["./assets/app.js.stefon"]
   })

(defn alink
  "Make link to compiled assets"
  [asset]
  (stefon/link-to-asset asset stefon-setup))

(defn embed
  "Replaces text by pattern"
  [t k v]
  (clojure.string/replace t (re-pattern (name k)) v))

(reval 'slag.core "api")
