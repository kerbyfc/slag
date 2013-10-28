(defres "/api/databases" []

  (merge
   web-api
   {
    :service-available? true
    :post! (=> ctx :data cfg :data :cfghome home
               (let [dbc (slag.core/get-db-conn-options cfg)
                     cfg (assoc cfg :cfghome (get-config-path home))]
                   (spit (str (:cfghome cfg) ) (to-json cfg {:pretty true}))
                   (println ">>>>>>>>>>>>> init = " (init))
                   (if-let [conf (init)]
                     (do
                       (println conf )
                       (to-json conf))
                     (do
                       (println (to-json {:error setup-error}))
                       (to-json {:error setup-error}))
                     )
                 ))

    :handle-ok (=> ctx (to-json databases-preset))
    }))
