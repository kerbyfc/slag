(ns slag.utils
  (:use
   [clojure.string :only [join split]]
   slag.core)
  (:require
   [clojure.string :refer [trim]]
   [clojure.inspector :as clj-inspector]
   [clojure.java.io :refer [file]])
  (:import
   [java.lang.reflect]))

(defn get-classpath
  "show java classpath or classpath of concrete library"
  [& args]
  (let [urls (map #(str (.getFile %)) (.getURLs (java.lang.ClassLoader/getSystemClassLoader)))]
    (def found (if (>= (count args) 1)
       (filter #(re-find (re-pattern (first args)) (str %)) urls)
       urls))
    (println found)
    found))

(defn lget
  "Lazy var get"
  [s]
  (if-let [v (find-var s)]
    (var-get v)))

(defn pwd []
  (clojure.string/join "/" (-> *file*
               java.io.File.
               .getPath
               (clojure.string/split #"\/")
               drop-last)))

(defn usr-root
  []
  (reval.core/locate-user-root))

(defn get-root
  [what?]
  ((find-var (clojure.core/symbol (str "slag.utils/" what? "-root")))))

(defn get-config-path
  [from]
  (str (get-root from) "/slag.json"))

(defn load-config
 [from]
 (cheshire.core/parse-stream (clojure.java.io/reader (get-config-path from)) true))

(defn app-root
  []
  (let [root (reval.core/locate-application-root 'slag.web)]
    (if (reval.core/jar? root)
      (reval.core/location root)
      root)))

(defn isUp?
  []
  (not (nil? (find-var 'slag.core/config))))

(defn setup
  "Try to load config files"
  []
  (try
    (intern 'slag.core 'config (load-config "usr"))
    (catch Exception e
      (try
        (intern 'slag.core 'config (load-config "app"))
        (catch Exception e))))
  (isUp?))

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

(defn !
  "Inspect object in swing interface"
  [obj]
  (def frame (clj-inspector/inspect-tree obj))
  (doto frame
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

(defmacro def-by-keyword
  [kwd value]
  `(def ~(symbol (clojure.core/name kwd)) ~value))
