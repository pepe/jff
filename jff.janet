(import termbox :as tb)

(defn to-cells [msg &opt col row style]
  (default col 0)
  (default row 0)
  (def fg (if style tb/black tb/white))
  (def bg (if style tb/white tb/black))
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

(defn main [_ &opt prompt prefix]
  (default prompt "")
  (default prefix "")
  (def d (->> (:read stdin :all)
              (string/split "\n")
              (filter |(not (empty? $)))
              (map |[(string/slice $ (length prefix) -1) 0])
              ))
  (assert d)
  (var res "")
  (defer (tb/shutdown)
    (var sd d)
    (tb/init)
    (def s @"")
    (def cols (tb/width))
    (def rows (dec (tb/height)))
    (def e (tb/event))
    (var i 1)
    (var pos 0)

    (to-cells prompt 0 rows)
    (for i 0 (length d)
      (to-cells (get-in sd [i 0]) 0 (- (- rows i) 2)
                (when (= pos i) :inv)))
    (to-cells (string/format "%d/%d" (length d) (length sd)) 0 (dec rows))
    (tb/present)

    (while (tb/poll-event e)
      (tb/clear)
      (def c (tb/event-char e))
      (def k (tb/event-key e))
      (if (zero? c)
        (case k
              tb/key-ctrl-n (and (> (dec (length sd)) pos) (++ pos))
              tb/key-ctrl-p (and (pos? pos) (-- pos))
              tb/key-backspace (buffer/popn s 1)
              tb/key-enter
              (do
                (set res (string prefix (or (get-in sd [pos 0]) s)))
                (break)))
        (if (< c 255)
         (buffer/push-byte s c)
         (error "Do not know UTF-8")))
      (to-cells (string prompt s) 0 rows)
      (def cg (mg (string s)))
      (set sd
        (as->
         (map (fn [[item _]] [item (first (peg/match cg item))]) d) r
         (filter |(number? (last $)) r)
         (sort r (fn [a b] (< (last b) (last a))))))
      (to-cells (string/format "%d/%d" (length d) (length sd)) 0 (dec rows))
      #(to-cells (string k) 0 (dec rows))
      (for i 0 (min (length sd) rows)
        (to-cells (first (get sd i)) 0 (- (- rows i) 2)
                  (when (= pos i) :inv)))
      (tb/present)
      (+= i 1)))
  (print res))
