(defres "/setup" []

  {
   :exists? (=> ctx
                (not (nil? (find-ns 'slag.config))))

   :post! (=> ctx
              (println ctx))

   :handle-ok "OK"

   }


  )
