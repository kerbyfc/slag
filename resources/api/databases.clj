(defres "/api/databases" []

  (merge
   web-api
   {
    :service-available? true
    :handle-ok (=> ctx (generate-string slag.db/dbs))
    :post! (=> ctx :request r :data cfg :data :name dbtype :data :cfghome home
               (let [dbc (get-full-db-conn-options dbtype cfg)
                     cfg (assoc cfg :cfghome (str (get-root home) "/slag.json"))]
                 (println cfg)
                 (open-global-connection (get-full-db-conn-options dbtype cfg))
                 (do-migrations)
                 (spit (str (:cfghome cfg) ) (generate-string cfg {:pretty true}))
                 {:created true}
                 ))
    }))
