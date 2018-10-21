(cl-loop
 for (drawer-name-case point-location create inside)
 in (reduce #'cartesian-product '((lower upper random)
                                  (beginning end random)
                                  (t nil)
                                  (t nil)))
 do
 (eval
  `(progn
     (if ,create
         (make-test no-drawer
                    ("{* Some heading"
                     ":PROPERTIES:"
                     ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                     ":END:"
                     "<           "
                     "≤≥     "
                     ">}")
                    "RESOURCES"
                    ,drawer-name-case
                    ,point-location
                    ,create
                    ,inside
                    )
       (make-test no-drawer
                    ("{* Some heading"
                     ":PROPERTIES:"
                     ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                     ":END:"
                     "}")
                    "RESOURCES"
                    ,drawer-name-case
                    ,point-location
                    ,create
                    ,inside
                    ))
     (make-test empty-drawer+upper-case
                ("{* Some heading"
                 ":PROPERTIES:"
                 ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                 ":END:"
                 "<:RESOURCES:"
                 "≤≥:END:"
                 ">}")
                "RESOURCES"
                ,drawer-name-case
                ,point-location
                ,create
                ,inside
                )
     (make-test empty-drawer+lower-case
                ("{* Some heading"
                 ":PROPERTIES:"
                 ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                 ":END:"
                 "<:resources:"
                 "≤≥:end:"
                 ">}")
                "RESOURCES"
                ,drawer-name-case
                ,point-location
                ,create
                ,inside
                )
     (make-test empty-drawer+random-case
                ("{* Some heading"
                 ":PROPERTIES:"
                 ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                 ":END:"
                 "<:reSouRceS:"
                 "≤≥:eNd:"
                 ">}")
                "RESOURCES"
                ,drawer-name-case
                ,point-location
                ,create
                ,inside
                )
     (make-test drawer-1
                ("{* Some heading"
                 ":PROPERTIES:"
                 ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                 ":END:"
                 "<:RESOURCES:"
                 "≤- element1"
                 "≥:END:"
                 ">}")
                "RESOURCES"
                ,drawer-name-case
                ,point-location
                ,create
                ,inside
                )
     (make-test drawer-many
                ("{* Some heading"
                 ":PROPERTIES:"
                 ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                 ":END:"
                 "<:RESOURCES:"
                 "≤- element1"
                 "- element2"
                 "- element3"
                 "≥:END:"
                 ">}")
                "RESOURCES"
                ,drawer-name-case
                ,point-location
                ,create
                ,inside
                ))))
