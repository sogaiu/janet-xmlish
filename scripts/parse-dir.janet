(import ../janet-xmlish/grammar :prefix "")

# usage: <script> <dir-path>
#
# * <dir-path> - path to directory containing xml files
#
# output:
#
# * stdout:
#   * paths with successful parses
#   * counts of successes and fails at end
#
# * stderr:
#   * paths with failed parses

# XXX: does not recursively descending into directory
(defn main
  [_ & args]

  (def dir (get args 0))

  (when (not (= :directory (os/stat dir :mode)))
    (errorf "expected directory path argument: %s" dir))

  (var success 0)
  (var fail 0)

  (def bom "\xEF\xBB\xBF")

  (each p (os/dir dir)
    (def cp (string dir "/" p))
    (when (= :file (os/stat cp :mode))
      (def content (slurp cp))
      (def start (if (string/has-prefix? bom content) 3 0))
      (def res (peg/match xmlish-peg content start))
      (if (not res)
        (do (++ fail) (eprint cp))
        (do (++ success) (print cp)))))

  (printf "success: %d" success)
  (printf "fail: %d" fail))

