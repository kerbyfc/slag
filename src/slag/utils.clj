(ns slag.utils
  (:require [clojure.string :refer [trim]]
            [clojure.inspector :as clj-inspector])
  (:import  [java.lang.reflect]))

(defn get-classpath
  "show java classpath or classpath of concrete library"
  [& args]
  (let [urls (map #(str (.getFile %)) (.getURLs (java.lang.ClassLoader/getSystemClassLoader)))]
    (def found (if (>= (count args) 1)
       (filter #(re-find (re-pattern (first args)) (str %)) urls)
       urls))
    (println found)
    found))

(defn in-path?
  "search entry in classpath"
  [query]
  (println (str "SEARCH '" query "' IN CLASSPATH"))
  (not (empty? (get-classpath query))))

(defn chk-char
  [string ch fun]
  (let [s (str (cond (number? fun)
        (nth string fun)
        :else (apply fun [string])))]
    (= (str ch) s)))

(defn Fn
  "Create function from string"
  [body]
  (let [bd (trim body)
        rc (if (chk-char body ")" last) "" ")")
        lc (if (chk-char body "(" first) "" "(")]
  (eval (read-string (str "#" lc body rc)))))

(def inspectors (ref []))

(defn !
  "Inspect object in swing interface"
  [obj]
  (def frame (clj-inspector/inspect-tree obj))
  (doto frame
    (.setLocation 0 (* 400 (count @inspectors)))
    (.setAlwaysOnTop true))
  (println (.getDeclaredMethods obj)))

(defmacro do-while
  "Repeatedly executes body while test expression is true. Presumes
  some side-effect will cause test to become false/nil. Returns nil"
  [test & body]
  `(loop []
     (when ~test
       ~@body
       (recur))))
