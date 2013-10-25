(defres "/api/databases" []

  (merge
   web-api
   {
    :service-available? true
    :handle-ok (=> ctx (generate-string slag.db/dbs))
    :post! (=> ctx :request r :data cfg :data :name dbtype :data :cfghome home
               (let [dbc (get-db-conn-options dbtype cfg)
                     cfg (assoc cfg :cfghome (get-config-path home))]
                 (println cfg)
                 (open-global-connection dbc)
                 (spit (str (:cfghome cfg) ) (generate-string cfg {:pretty true}))
                 (setup)
                 (generate-string {:configured (isUp?)})
                 ))
    }))
