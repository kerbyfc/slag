(resource* "servers"

           {
            :available-media-types ["text/plain"]
            :allowed-methods [:get :put :post]
            }


           "/:id" [id] {
                        :handle-ok (with-req r
                                     (format "SERVER WITH ID %s" id))
                        }

           "" [] {

                  :exists? (with-req r
                             (= "servers" (get-in r [:query-params "word"])))

                  :handle-ok (str "SERVERS LIST")
                  }

           )
