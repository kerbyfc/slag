(ns slag.config)
(in-ns 'slag.core)

(def global-conn-conf nil)
(def global-conn-established? false)

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

(defn isUp?
  []
  (not (nil? (find-var 'slag.core/conf))))

(defn get-db-conn-options
  ([dbtype options]
   (let [helper (find-var (clojure.core/symbol (str "korma.db/" dbtype)))]
     (helper options))
   )
  ([]
   (if (isUp?)
     (get-db-conn-options (get (lget 'slag.core/conf) :name) (lget 'slag.core/conf))))
  )

(defn open-global-connection
  ([conf]
   (if (not (and (= global-conn-conf conf) global-conn-established?))
     (do
       (def global-conn-conf conf)
       (if global-conn-established?
         (close-global))
       (open-global conf)
       (defdb db conf) ; TODO check@!
       (def global-conn-established? true)
       )
     )
   (if global-conn-established?
     (migrate)))
  ([]
   (open-global-connection (get-db-conn-options))
   ))




;;;;;;;;;;;;;;;;;;; JUST DO TI! ) ;;;;;;;;;;;;;;;;;;;;


(def awaked? (ref false))

(defn make-me-up

	)

(def awake (memoize #(do
											 (println "HI")
											 (dosync
												(ref-set awaked? true))
											 true)))

(defn wake-up
	[]
	(try
		(awake)
		(catch Exception e
			(dosync
			 (ref-set awaked? false))
			false)))

(wake-up)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defn setup
  "Try to load config files"
  []
  (intern 'slag.core 'conf (load-config "usr"))
  (intern 'slag.core 'conf (load-config "app"))

  ;(try
  ;  (intern 'slag.core 'conf (load-config "usr"))
  ;  (catch Exception e
  ;    (println "load usr conf" (.getMessage e))
  ;    (try
  ;      (intern 'slag.core 'conf (load-config "app"))
  ;      (catch Exception e
  ;        (println "load app conf" (.getMessage e))))))
  (isUp?))
