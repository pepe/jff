(var prefix nil)

(defn prepare [l]
  (unless prefix (set prefix (first (peg/match '(<- (some "../")) l))) (tracev prefix))
  (string/slice l (length prefix) -1))

(def grammar '(<- (some 1)))

(defn transform [res]
  (tracev res)
  (print (string prefix (first res))))
