(ns slag.init)
(in-ns 'slag.core)

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
 (cheshire.core/parse-stream (clojure.java.io/reader (get-config-path from)) true))

;;;;; CONNECTION AWAIKING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(def config (ref {}))
(def config-error (ref ""))

(defn get-db-conn-options

	([dbtype options]
   (let [helper (find-var (clojure.core/symbol (str "korma.db/" dbtype)))]
     (helper options)))

	([]
   (if (isUp?)
     (get-db-conn-options (get (lget 'slag.core/conf) :name) (lget 'slag.core/conf))))
  )

(def setup
	(memoize
	 (fn [cfgtype]

		 (try

			 (let [conf (load-config cfgtype)]

				 (open-global conf) ; configure global db-connection
				 (defdb db conf)

				 (dosync
					(ref-set config conf))

				 conf) ; return config

			 (catch Exception e ; store exception
				 (dosync
					(ref-set config-error (.getMessage e))))))))

(defn initialize

	)

(defn init
	(if-let [conf (setup "usr")]
		(initialize)
		(if-let [conf setup "app"])
			(initialize)
		))

