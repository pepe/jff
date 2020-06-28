(def grammar '(<- (to ".")))

(defn transform [res]
  (print (string/ascii-upper (first res))))
