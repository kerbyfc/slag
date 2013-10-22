(defres "/" [] {
   :available-media-types ["text/html"]
   :handle-ok application-template})

(defres ["/templates/:path", :path #"[\w\/]+"] [path] {
   :available-media-types ["text/plain"]
   :handle-ok (str (slurp (clojure.java.io/resource (str "assets/tpl/" path ".haml"))))})
