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
                    nil
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
                  nil
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
                nil
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
                nil
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
                nil
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
                ("element1")
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
                ("element1"
                 "element2"
                 "element3")
                ,drawer-name-case
                ,point-location
                ,create
                ,inside
                )
     (make-test multiple-headers
                ("* Random first header"
                 ":PROPERTIES:"
                 ":ID: EADF0BAA-D51F-11E8-A3DB-80E650001438"
                 ":END:"
                 ":RESOURCES:"
                 "- wrong-element-1"
                 "- wrong-element-2"
                 "- wrong-element-3"
                 ":END:"
                 ""
                 "{* Some heading"
                 ":PROPERTIES:"
                 ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                 ":END:"
                 "<:RESOURCES:"
                 "≤- element1 is a multiple"
                 "  lines element"
                 "- element2"
                 "≥:END:"
                 ">}"
                 "* Random last header"
                 ":PROPERTIES:"
                 ":ID: EADF0BAA-D51F-11E8-A3DB-80E650001438"
                 ":END:"
                 ":RESOURCES:"
                 "- wrong-element-4"
                 "- wrong-element-5"
                 ":END:"
                 "")
                "RESOURCES"
                ("element1 is a multiple lines element"
                 "element2")
                ,drawer-name-case
                ,point-location
                ,create
                ,inside
                ))))
