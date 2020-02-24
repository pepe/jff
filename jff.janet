(def d ["Pepa" "Depa" "Repan"])

(while true
  (def b (-> (getline ">") string/trim))
  (each n d (printf "%j" (peg/match ~(some ,b) n))))

