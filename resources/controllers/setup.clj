(defresources "setup"

  (merge web-api-conf {:service-available? true})

  "/1" [] {
           :handle-ok "STEP 1"
           }

  )
