(import termbox :as tb)

(defn to-cells [msg &opt col row fg bg]
  (default col 0)
  (default row 0)
  (default fg tb/black)
  (default bg tb/white)
  (for c 0 (length msg)
    (tb/cell (+ col c) row (msg c) fg bg)))


(defn g [buf]
  (def b (if (empty? buf) 1 buf))
  {:exact ~(some ,b)
   :in ~(* (some (if-not ,b 1)) :exact)
   :main ~(+
           (if :exact (constant 10))
           (if :in (constant 2)))})

(defn main [_ args]
  (def d (string/split "\n" (:read stdin :all)))
  (var res "")
  (defer (tb/shutdown)
    (var sd d)
    (tb/init)
    (def prompt args)
    (var s @"")
    (def cols (tb/width))
    (def rows (dec (tb/height)))
    (def e (tb/event))
    (var i 1)
    (var pos 0)

    (to-cells prompt 0 rows)
    (for i 0 (length d)
      (to-cells (get sd i) 0 (- (- rows i) 2)
                (if (= pos i) tb/black tb/white) (if (= pos i) tb/white tb/black)))
    (tb/present)

    (while (tb/poll-event e)
      (tb/clear)
      (def c (tb/event-char e))
      (def k (tb/event-key e))
      (if (zero? c)
        (case k
              16 (and (> (dec (length sd)) pos) (++ pos))
              14 (and (pos? pos) (-- pos))
              127 (buffer/popn s 1)
              13 (do
                   (set res (or (get-in sd [pos 0]) s))
                   (break)))
        (if (< c 255)
         (buffer/push-byte s c)
         (error "Do not know UTF-8 still")))
      (to-cells (string prompt s) 0 rows)
      (def cg (g (string s)))
      (set sd
        (as->
         (map (fn [item] [item (first (peg/match cg item))]) d) r
         (filter |(number? (last $)) r)
         (sort r (fn [a b] (< (last b) (last a))))))
      (to-cells (string k) 0 (dec rows))
      (for i 0 (min (length sd) rows)
        (to-cells (first (get sd i)) 0 (- (- rows i) 2)
                  (if (= pos i) tb/black tb/white) (if (= pos i) tb/white tb/black)))
      (tb/present)
      (+= i 1)))
  (print res))

