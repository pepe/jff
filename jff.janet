(import termbox :as tb)
(import utf8)

(defn to-cells [message &opt col row style]
  (default col 0)
  (default row 0)
  (def fg (if style tb/black tb/white))
  (def bg (if style tb/white tb/black))
  (def msg (utf8/decode message))

  (for c 0 (length msg)
    (tb/cell (+ col c) row (msg c) fg bg)))

(defn mg [b]
  (peg/compile
   {:exact ~(some ,b)
    :in ~(* (some (if-not ,b 1)) :exact)
    :fuzzy (tuple
             '*
             ;(seq [i :in b
                    :let [c (string/from-bytes i)]]
               ~(* (any (if-not ,c 1)) ,c)))
    :main ~(+
             (if :exact (constant 3))
             (if :in (constant 2))
             (if :fuzzy (constant 1)))}))

(defn prepare-input [prefix]
  (->> (:read stdin :all)
       (string/split "\n")
       (filter |(not (empty? $)))
       (map |[(string/slice $ (length prefix) -1) 0])))

(defn match-n-sort [d s]
  (def cg (mg (string s)))
  (as->
    (map (fn [[item _]] [item (first (peg/match cg item))]) d) r
    (filter |(number? (last $)) r)
    (sort r (fn [a b] (if (= (last a) (last b))
                        (< (length (first a)) (length (first b)))
                        (< (last b) (last a)))))))

(defn main [_ &opt prompt prefix]
  (default prompt "")
  (default prefix "")
  (def d (prepare-input prefix))
  (assert d)
  (var res "")

  (defer (tb/shutdown)
    (tb/init)
    (let [s @""
          cols (tb/width)
          rows (dec (tb/height))
          e (tb/event)]

      (var pos 0)

      (tb/clear)
      (to-cells prompt 0 0)
      (for i 0 (length d)
        (to-cells (get-in d [i 0]) 0 (+ i 2) (when (= pos i) :inv)))
      (to-cells (string/format "%d/%d" (length d) (length d)) 0 1)
      (tb/present)

      (var sd d)
      (while (tb/poll-event e)
        (let [c (tb/event-char e)
              k (tb/event-key e)]
          (if (zero? c)
            (case k
                  tb/key-ctrl-n (and (> (dec (length sd)) pos) (++ pos))
                  tb/key-ctrl-p (and (pos? pos) (-- pos))
                  tb/key-space (do
                                (buffer/push-string s " ")
                                (set sd (match-n-sort d s)))
                  tb/key-backspace2
                  (do (buffer/popn s (cond
                                       (> (last s) 0x7F) 2
                                       (> (last s) 0xC0) 3
                                       (> (last s) 0xE0) 4
                                       1))
                      (set sd (match-n-sort d s)))
                  tb/key-enter
                  (do
                    (set res (string prefix (or (get-in sd [pos 0]) s)))
                    (break)))
            (do
              (buffer/push-string s (utf8/encode [c]))
              (set sd (match-n-sort d s)))))


        (tb/clear)
        (to-cells (string prompt s) 0 0)
        (to-cells (string/format "%d/%d" (length d) (length sd)) 0 1)
        (for i 0 (min (length sd) rows)
          (to-cells (first (get sd i)) 0 (+ i 2) (when (= pos i) :inv)))
        (tb/present))))
  (print res))
