(cl-loop
 for (drawer-name-case point-location)
 in (cartesian-product '(lower upper random) '(beginning end random))
 do
 (eval
  `(progn
     (make-test empty-drawer+upper-case
                ("{* Some heading"
                 ":PROPERTIES:"
                 ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                 ":END:"
                 "<:RESOURCES:"
                 ":END:"
                 ">}")
                "RESOURCES"
                ,drawer-name-case
                ,point-location
                )
     (make-test empty-drawer+lower-case
                ("{* Some heading"
                 ":PROPERTIES:"
                 ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                 ":END:"
                 "<:resources:"
                 ":end:"
                 ">}")
                "RESOURCES"
                ,drawer-name-case
                ,point-location
                )
     (make-test empty-drawer+random-case
                ("{* Some heading"
                 ":PROPERTIES:"
                 ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                 ":END:"
                 "<:reSouRceS:"
                 ":eNd:"
                 ">}")
                "RESOURCES"
                ,drawer-name-case
                ,point-location
                ))))
