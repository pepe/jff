(import termbox :as tb)
(import utf8)

(defn to-cells [message &opt col row style]
  (default col 0)
  (default row 0)

  (def fg (case style
            :inv tb/black
            :soft tb/magenta
            tb/white))
  (def bg (cond
            (= :inv style) tb/green
            tb/black))
  (def msg (utf8/decode message))
  (for c 0 (length msg)
    (tb/cell (+ col c) row (msg c) fg bg)))

(defn prepare-input [prefix input]
  (->> input
       (string/split "\n")
       (filter |(not (empty? $)))
       (map |[(string/slice $ (length prefix) -1) 0])))

(defn mg [b]
  (peg/compile
    ['*
     ;(seq [i :in b
            :let [c (string/from-bytes i)]]
        ~(* (any (if-not ,c (* (constant -1) 1))) ,c))]))

(defn choose [prmt choices]
  (var res nil)
  (defer (tb/shutdown)
    (tb/init)

    (def cols (tb/width))
    (def rows (tb/height))
    (def e (tb/event))
    (var pos 0)
    (var s @"")
    (var sd choices)
    (def lc (length choices))

    (defn match-n-sort [d s]
      (def cg (mg (string s)))
      (def res
        (reduce
          (fn [a [i _]]
            (def fs (string/find s i))
            (cond
              (or (zero? fs)
                  (string/has-suffix? s i)) (array/push a [i 100])
              fs (array/push a [i (- 50 fs)])
              (if-let [p (and (< 1 (length s)) (:match cg i))] (array/push a [i (reduce + 0 p)]) a)))
          (array/new (length d)) d))
      (if (< (length res) lc)
        (sort-by (fn [[i s]] (- (- s (/ (length i) 10)))) res)
        res))

    (defn show-ui []
      (tb/clear)
      (to-cells (string/format "%d/%d %s%s_"
                               (length sd) lc prmt (string s))
                0 0)
      (for i 0 (min (length sd) rows)
        (def [term score] (get sd i))
        (to-cells term 0 (inc i)
                  (cond
                    (= pos i) :inv
                    (neg? score) :soft)))
      (tb/present))

    (show-ui)

    (defn reset-pos [] (set pos 0))
    (defn inc-pos [] (and (> (dec (length sd)) pos) (++ pos)))
    (defn dec-pos [] (and (pos? pos) (-- pos)))
    (defn quit [] (tb/shutdown) (os/exit 1))

    (defn add-char [c]
      (reset-pos)
      (buffer/push-string s (utf8/encode [c]))
      (set sd (match-n-sort sd s)))

    (defn complete []
      (reset-pos)
      (set s (buffer (get-in sd [pos 0])))
      (set sd [[(string s) 0]]))

    (defn erase-last []
      (reset-pos)
      (when-let [ls (last s)]
        (buffer/popn s
                     (cond
                       (> ls 0xE0) 4
                       (> ls 0xC0) 3
                       (> ls 0x7F) 2
                       1))
        (cond
          (= (length sd) lc) (break)
          (not (empty? s)) (set sd (match-n-sort choices s))
          (set sd choices))))

    (while (and (nil? res) (tb/poll-event e))
      (def c (tb/event-char e))
      (def k (tb/event-key e))
      (if (zero? c)
        (case k
          tb/key-ctrl-n (inc-pos) tb/key-ctrl-j (inc-pos)
          tb/key-arrow-down (inc-pos)
          tb/key-ctrl-p (dec-pos) tb/key-ctrl-k (dec-pos)
          tb/key-arrow-up (dec-pos)
          tb/key-space (add-char (chr " "))
          tb/key-tab (complete)
          tb/key-backspace2 (erase-last)
          tb/key-esc (quit) tb/key-ctrl-c (quit)
          tb/key-enter (set res (or (get-in sd [pos 0]) s)))
        (add-char c))
      (show-ui))
    (tb/clear))
  res)

(defn main [_ &opt prmt prefix]
  (default prmt "")
  (default prefix "")
  (->> (:read stdin :all)
       (prepare-input prefix)
       (choose prmt)
       (string prefix)
       print))
