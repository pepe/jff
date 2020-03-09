(import termbox :as tb)

(defn to-cells [msg &opt col row]
  (default col 0)
  (default row 0)
  (for c 0 (length msg)
    (tb/cell (+ col c) row (msg c) tb/black tb/white)))

(def prompt "HOHOHO> ")

(var s @"")

(def d ["pepa" "depa" "repan" "pepan"])

(defn g [b]
  {:exact ~(some ,b)
   :in ~(* (some (if-not ,b 1)) :exact)
   :main ~(+
           (if :exact (constant 10))
           (if :in (constant 2)))})

(defn main [args]
  (defer (tb/shutdown)
    (tb/init)
    (def- cols (tb/width))
    (def- rows (dec (tb/height)))

    (def e (tb/event))

    (var i 1)
    (to-cells prompt 0 rows)
    (tb/present)

    (while (tb/poll-event e)true
      (to-cells prompt 0 rows)
      (def c (tb/event-char e))
      (when (= (tb/event-key e) 13) (break))
      (if (< c 255)
        (buffer/push-byte s c)
        (error "Do not know UTF-8 still"))

      (to-cells s 8 rows)
      (def cg (g (string s)))
      (def sd (filter |(peg/match cg $) d))
      (for i 0 (length sd)
        (to-cells (string (get sd i) " - " (first (peg/match cg (get sd i)))) 0 (dec (- rows i))))
      (tb/present)
      (+= i 1)
      (tb/clear)))
  (print s))


