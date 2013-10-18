
(ns syslog.core
  (:use [utils])
  (:import [java.io PrintStream ByteArrayOutputStream]

           [org.productivity.java.syslog4j.util SyslogUtility]

           ; SSL
           [org.productivity.java.syslog4j.server.impl.net.tcp.ssl SSLTCPNetSyslogServer SSLTCPNetSyslogServerConfig]

           ; EXCEPTIONS
           [org.productivity.java.syslog4j SyslogRuntimeException]

           [org.productivity.java.syslog4j.server.impl.event Handler]
           [org.productivity.java.syslog4j.server SyslogServer SyslogServerConfigIF SyslogServerIF SyslogServerEventHandlerIF]

           [org.productivity.java.syslog4j.server.impl.event.printstream PrintStreamSyslogServerEventHandler]))

(declare baos handler)

(defn create-handler
  "Create eventHandler for all servers"
  []
  (def baos (ByteArrayOutputStream.))
  (def ps (PrintStream. baos))
  (Handler ps))

(def handler (create-handler))

(defn configure-server
  "Set server port, add eventHandler"
  [config port structured]
  (doto config
    (.setPort port)
    (.setUseStructuredData structured)
    (.addEventHandler handler)))

(defn create-server
  "Create server for specific protocol (udp/tcp/ssl)"
  [{:keys [protocol port host structured]}]
  (if (= protocol "ssl")
    (try
      (SyslogServer/createInstance "ssl" (SSLTCPNetSyslogServerConfig.))
      (catch SyslogRuntimeException e (println (.getMessage e)))))
  (def server (SyslogServer/getInstance protocol))
  (def server-config (configure-server (.getConfig server) port structured))
  (if (not (= host nil))
    (.setHost server-config host))

  server)

(defn -main [& args] ())

(def server (create-server {:protocol "ssl"
                            :structured true
                            :port 4444}))
(.run server)
