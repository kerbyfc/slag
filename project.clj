(defproject slag "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [

                 ; FIXME lobos uses clojure 1.4
                 [lobos "1.0.0-beta1"]

                 [org.clojure/clojure "1.5.1"]

								 ; UTILS
                 [cheshire "5.2.0"]
                 [reval "0.1.1-SNAPSHOT"]

                 [clojurewerkz/quartzite "1.1.0"]
                 [com.github.ragnard/hamelito "0.2.1"]

                 ; WEB
                 [cwk "0.1.4-SNAPSHOT"]
                 [circleci/stefon "0.5.0-SNAPSHOT"]


                 ; DATABASE
                 [korma "0.3.0-RC6"]

                 [org.clojars.puppetdb/postgresql "9.2-1002.jdbc4"]
                 [com.h2database/h2 "1.3.170"] ; TODO check
                 [org.xerial/sqlite-jdbc "3.7.2"] ; TODO check

								 ; SYSLOG
                 [org.syslog4j/syslog4j "0.9.30"]
								 [com.sun.jna/jna "3.0.9"]
								 [org.apache.directory.studio/org.apache.commons.pool "1.6"]
                 [org.apache.directory.studio/org.apache.logging.log4j "1.2.17"]

								 ; MYCROFT STACK
								 ;[hiccup "0.3.5"]
								 ;[org.clojure/tools.logging "0.1.2"]
                 ;[org.clojure/java.jmx "0.1"]
                 ;[ring/ring-jetty-adapter "1.2.0"]
                 ;[compojure "1.1.5"]

                 ]
  :ring {:handler slag.web/handler
         :port 8000
         :auto-reload? true}
  :java-source-paths ["src/slag/java"]
  :main slag.core
  :profiles {:uberjar {:aot :all}})
