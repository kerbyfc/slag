(ns slag.init)
(in-ns 'slag.core)

(def config nil)
(def setup-error "")

;;;;; APPLICATION LOCATING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn usr-root
  []
  (reval.core/locate-user-root))

(defn app-root
  []
  (let [root (reval.core/locate-application-root 'slag.web)]
    (if (reval.core/jar? root)
      (reval.core/location root)
      root)))

(defn get-root
  [what?]
  ((find-var (clojure.core/symbol (str "slag.core/" what? "-root")))))

;;;;; CONFIG LOADING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn get-config-path
  [from]
  (str (get-root from) "/slag.json"))

(defn load-config
 [from]
 (parse-json-stream (clojure.java.io/reader (get-config-path from)) true))

;;;;; DATABASE CONNECTION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn get-db-conn-options

	([conf]
   (let [helper (find-var (clojure.core/symbol (lower-case (str "korma.db/" (:name conf)))))]
     (helper conf)))

	([]
   (if config
     (get-db-conn-options config)))
  )

;;;;; INITIALIZATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(def setup
	(memoize
	 (fn [cfgtype]

		 (try

			 (let [conf (load-config cfgtype)]

         (println "CONF" conf cfgtype)

         ; configure global db-connection
				 (open-global (get-db-conn-options conf))
				 (defdb db conf)
         (migrate)

				 (def config conf)

				 true) ; return config if all is good

			 (catch Exception e ; store exception
				 (do
           (def setup-error (.getMessage e)))
         )))))

(defn init
  []
  (if-let [conf (setup "usr")]
    conf
    (setup "app")))
