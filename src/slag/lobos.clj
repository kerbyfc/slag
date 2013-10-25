(ns slag.lobos
  (:refer-clojure :exclude [alter drop
                            bigint boolean char double float time])
  (:use
   (lobos [migration :only [defmigration]] core schema)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; helpers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn surrogate-key [table]
  (integer table :id :auto-inc :primary-key))

(defn timestamps [table]
  (-> table
      (timestamp :updated_on)
      (timestamp :created_on (default (now)))))

(defn refer-to [table ptable]
  (let [cname (-> (->> ptable name butlast (apply str))
                  (str "_id")
                  keyword)]
    (integer table cname [:refer ptable :id :on-delete :set-null])))

(defmacro tbl [name & elements]
  `(-> (table ~name)
       (timestamps)
       ~@(reverse elements)
       (surrogate-key)))

;;;;;;;;;;;;;;;;;;;;;;;;;; migrations ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmigration add-users-table
  (up [] (create
          (tbl :users
            (varchar :name 100 :unique)
            (check :name (> (length :name) 1)))))
  (down [] (drop (table :users))))

(defmigration add-posts-table
  (up [] (create
          (tbl :posts
            (varchar :title 200 :unique)
            (text :content)
            (refer-to :users))))
  (down [] (drop (table :posts))))

(defmigration add-comments-table
  (up [] (create
          (tbl :comments
            (text :content)
            (refer-to :users)
            (refer-to :posts))))
  (down [] (drop (table :comments))))

