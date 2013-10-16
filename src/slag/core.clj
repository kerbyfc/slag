(ns slag.core
	(:use [slag.utils]
				[slag.web :only [start-service]])
  (:gen-class))

(defn -main
  "Run web service"
  [& args]
  (start-service 8000))


