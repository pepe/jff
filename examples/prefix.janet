(var prefix nil)

(defn prepare [l]
  (unless prefix (set prefix (first (peg/match '(<- (some "../")) l))))
  (string/slice l (length prefix) -1))

(defn transform [res]
  (print (string prefix res)))
