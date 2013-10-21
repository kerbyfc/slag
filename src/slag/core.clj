(ns slag.core
	(:use [slag.utils]
				[slag.web])
  (:require [cheshire.core :refer :all])
  (:gen-class))

(defn check-configuration
  "Checks if configuration file exists"
  []
  (if (find-ns 'slag.config)
    true
    (do
      (try
        (let [config-json (read-string (slurp "./config.json"))]
          (binding [*ns* *ns*]
            (in-ns 'slag.config)
            (doseq [kv (parse-string config-json)]
              (let [k (first kv)
                    v (second kv)]
                (def-by-keyword k v))
              ))
          true)
        (catch java.io.FileNotFoundException e
          false)))))

(check-configuration)

(defn -main
  "Run web service"
  [& args]
  (check-configuration)
  (start-service {:port 8000}))


