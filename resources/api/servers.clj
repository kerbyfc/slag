(defresources "/servers"

  (merge web-api {:available-media-types ["text/plain" "text/html"]})

  "/:id" [id] {
               :handle-ok (=> r
                              (format "SERVER WITH ID %s" id))
               }

  "" [] {

         :exists? (=> ctx :request :query-params "choice" c
                      (if (not (nil? (find {"1" "apple" "2" "orange"} c)))
                        {:choice c}))


         :handle-not-found (=> r :choice c
                               (format "<html>There is no value for the option &quot;%s&quot;"
                                       c))

         :handle-ok (=> ctx :choice c :representation :media-type mt
                        (condp = mt
                          "text/html" (format "<html><a href='#'>Your choice is: &quot;%s&quot;</a>." c)
                          "text/plain" (format "Your choice: \"%s\".\n" c))
                        )

         :handle-not-acceptable "Uh, Oh, I cannot speak those languages!"

         }

  )
