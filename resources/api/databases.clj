(defres "/api/databases" []
  (merge web-api {
                  :service-available? true
                  :handle-ok (=> ctx
                                 (get-available-dbs)
                                 )
                  }
         ))
