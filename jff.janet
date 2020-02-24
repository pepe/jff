(def d ["Pepa" "Depa" "Repan" "Pepan"])

(defn g [b]
  {:exact ~(some ,b)
   :in ~(* (some (if-not ,b 1)) :exact)
   :main ~(+
           (if :exact (constant 10))
           (if :in (constant 2)))})

(while true
  (def b (-> (getline ">") string/trim))
  (each n d (printf "%j" (peg/match (g b) n))))

