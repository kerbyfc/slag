(resource* "servers"

           {
            :available-media-types ["text/plain"]
            :allowed-methods [:get :put :post]
            }


           "/:id" [id] {
                        :handle-ok (fn [_] (format "SERVER WITH ID %s" id))
                        }

           "" [] {
                  :exists? (fn [{_ :request}] (= "servers" (get-in _ [:query-params "word"])))
                  :handle-ok (str "SERVERS LIST")
                  }

           )
