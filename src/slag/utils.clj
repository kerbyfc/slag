(ns slag.utils
  (:use
   [clojure.tools.namespace.find :only [find-namespaces-in-dir]]
   [clojure.string :only [join split]])
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

(defmacro require-from
  ""
  [dir & refs]
  `(let [namespaces# (find-namespaces-in-dir (file (str "./src/" (name ~dir))))]
     (map #(do
            (require %)
            (def x# (map symbol (map name (vec (clojure.set/intersection (set (map keyword (-> (ns-publics %) keys vec))) #{~@refs})))))
            (refer % :only x#)
            ) namespaces#)))

(defn has-file-extension? [file-name extensions]
  (let [extension-pattern (clojure.string/join "|" extensions)
        complete-pattern (str "^.+\\.(" extension-pattern ")$")
        extensions-reg-exp (re-pattern complete-pattern)]
    (if (re-find extensions-reg-exp file-name)
      true
      false)))

(defn get-files-from-directory [directory]
  (->> directory
       clojure.java.io/file
       file-seq
       (filter #(.isFile %))))

(defn get-file-names-from-directory [directory]
  (->> directory
       clojure.java.io/file
       file-seq
       (filter #(.isFile %))
       (map #(.getName %))))

(defn filter-on-extensions [files extensions]
  (filter #(has-file-extension? % extensions) files))

(defn get-files-with-extension [directory extensions]
  (-> directory
      get-file-names-from-directory
      (filter-on-extensions extensions)))

(defn pwd []
  (clojure.string/join "/" (-> *file*
               java.io.File.
               .getPath
               (clojure.string/split #"\/")
               drop-last)))

(defn load-from
  ""
  [dir & extensions]
  (let [path (clojure.string/join "/" [(slag.utils/pwd) dir])]
       (map #(load-file (clojure.string/join "/" [path %])) (get-files-with-extension path (vec (map name extensions))))))

(defn include
  ""
  [dir]
  (let [cwd (slag.utils/pwd)
        path (join "/" [cwd dir])]
    (map
     #(load (clojure.string/replace (join "." (drop-last (split (join "/" [path %]) #"\."))) (str cwd "/") ""))
     (get-files-with-extension path ["clj"]))))

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
