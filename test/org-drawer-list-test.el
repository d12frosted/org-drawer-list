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
         (make-list-test no-drawer
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
                    ,inside)
       (make-list-test no-drawer
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
                  ,inside))
     (make-list-test empty-drawer+upper-case
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
                ,inside)
     (make-list-test empty-drawer+lower-case
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
                ,inside)
     (make-list-test empty-drawer+random-case
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
                ,inside)
     (make-list-test drawer-1
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
                ,inside)
     (make-list-test drawer-many
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
                ,inside)
     (make-list-test ordered-list
                ("{* Some heading"
                 ":PROPERTIES:"
                 ":ID: 8366A66A-2DE6-401B-AF7F-0C03C33EA3BB"
                 ":END:"
                 "<:RESOURCES:"
                 "≤1. element1"
                 "2. element2"
                 "3. element3"
                 "4. element4"
                 "5. element5"
                 "6. element6"
                 "7. element7"
                 "8. element8"
                 "9. element9"
                 "10. element10 is a long,"
                 "    very long element"
                 "11. element11"
                 "12. element12"
                 "≥:END:"
                 ">}")
                "RESOURCES"
                ("element1"
                 "element2"
                 "element3"
                 "element4"
                 "element5"
                 "element6"
                 "element7"
                 "element8"
                 "element9"
                 "element10 is a long, very long element"
                 "element11"
                 "element12")
                ,drawer-name-case
                ,point-location
                ,create
                ,inside)
     (make-list-test multiple-headers
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
