# There are some common function to use with the -p arg

(defn remove-prefix
  "Suitable as prepare function, where you want to remove the prefix from all choices."
  [prefix]
  (fn [l] (string/slice l (length prefix) -1)))

(defn prepend-prefix [prefix]
  "Suitable as transform function, where you want to prepend the prefix to the selected."
  (fn [res] (print (string prefix res))))
