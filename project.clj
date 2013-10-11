(defproject slag "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.5.1"]

								 ; UTILS
								 [org.clojure/clojure-contrib "1.2.0"]
                 [org.clojure/tools.namespace "0.2.4"]

								 ; WEB STACK
								 [ring/ring-jetty-adapter "1.2.0"]
                 [compojure "1.1.5"]
                 [liberator "0.9.0"]

								 ; SYSLOG STACK
                 ;[org.syslog4j/syslog4j "0.9.30"]
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
       :auto-reload? true
       :auto-refresh? true}
	:java-source-paths ["src/slag/java"]
  :main slag.core
  :profiles {:uberjar {:aot :all}})
