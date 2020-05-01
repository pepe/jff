(import termbox :as tb)
(import utf8)

(defn to-cells [message &opt col row style]
  (default col 0)
  (default row 0)

  (let [fg (case style
           :inv tb/black
           :soft tb/magenta
           tb/white)
        bg (cond
           (= :inv style) tb/green
           tb/black)
        msg (utf8/decode message)]
    (for c 0 (length msg)
      (tb/cell (+ col c) row (msg c) fg bg))))

(defn mg [b]
  (peg/compile
    {:exact ~(some ,b)
     :in ~(* (some (if-not ,b 1)) :exact)
     :fuzzy (tuple
              '*
              ;(seq [i :in b
                     :let [c (string/from-bytes i)]]
                ~(* (any (if-not ,c 1)) ,c)))
     :main '(+
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

(defn choose [choices prmt]
  (var res nil)
  (defer (tb/shutdown)
    (tb/init)
    (let [cols (tb/width)
          rows (tb/height)
          e (tb/event)]

      (var pos 0)
      (var s @"")
      (var sd choices)

      (defn show-prompt []
        (tb/clear)
        (to-cells (string/format "%d/%d %s%s" (length sd) (length choices) prmt (string s)) 0 0)
        (for i 0 (min (length sd) rows)
          (let [[term score] (get sd i)]
            (to-cells term 0 (inc i) (cond (= pos i) :inv
                                           (= score 1) :soft))))
        (tb/present))

      (show-prompt)

      (defn inc-pos [] (and (> (dec (length sd)) pos) (++ pos)))

      (defn dec-pos [] (and (pos? pos) (-- pos)))

      (defn add-space []
        (buffer/push-string s " ")
        (set sd (match-n-sort choices s)))

      (defn complete []
        (set s (buffer (get-in sd [pos 0])))
        (set sd (match-n-sort choices s)))

      (defn erase-last []
        (when-let [ls (last s)]
          (buffer/popn s
                       (cond
                         (> ls 0xE0) 4
                         (> ls 0xC0) 3
                         (> ls 0x7F) 2
                         1))
           (set sd (match-n-sort choices s))))

      (defn quit [] (os/exit 1))

      (while (and (nil? res) (tb/poll-event e))
        (let [c (tb/event-char e)
              k (tb/event-key e)]
          (if (zero? c)
            (case k
                  tb/key-ctrl-n (inc-pos) tb/key-ctrl-j (inc-pos) tb/key-arrow-down (inc-pos)
                  tb/key-ctrl-p (dec-pos) tb/key-ctrl-k (dec-pos) tb/key-arrow-up (dec-pos)
                  tb/key-space (add-space)
                  tb/key-tab (complete)
                  tb/key-backspace2 (erase-last)
                  tb/key-esc (quit) tb/key-ctrl-c (quit)
                  tb/key-enter (set res (or (get-in sd [pos 0]) s)))
            (do
              (buffer/push-string s (utf8/encode [c]))
              (set sd (match-n-sort choices s)))))
        (show-prompt))))
  res)

(defn main [_ &opt prmt prefix]
  (default prmt "")
  (default prefix "")

  (print (string prefix (choose (prepare-input prefix) prmt))))
