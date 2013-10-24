(defres "/" []
  {
   :available-media-types ["text/html"]
   :handle-ok (-> (haml/html (slurp (clojure.java.io/resource "app.haml")))
                  (embed :__css__ (alink "css/app.css.stefon"))
                  (embed :__js__ (alink "js/app.js.stefon"))
                  (embed :__isUp__ (str (not (nil? (find-ns 'slag.config)))))
                  (embed :__app__ (app-root))
                  (embed :__usr__ (usr-root)))
   })

(defres ["/templates/:path", :path #"[\w\/]+"] [path] {
   :available-media-types ["text/plain"]
   :handle-ok (str (slurp (clojure.java.io/resource (str "assets/tpl/" path ".haml"))))})
