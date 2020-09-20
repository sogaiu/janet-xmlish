(import ./janet-xmlish/vendor/path)

(declare-project
 :name "janet-xmlish"
 :url "https://github.com/sogaiu/janet-xmlish"
 :repo "git+https://github.com/sogaiu/janet-xmlish.git")

(def proj-root
  (os/cwd))

(def proj-dir-name
  "janet-xmlish")

(def src-root
  (path/join proj-root proj-dir-name))

(declare-source
 :source [src-root])

(phony "netrepl" []
       (os/execute
        ["janet" "-e" (string "(os/cd \"" src-root "\")"
                              "(import spork/netrepl)"
                              "(netrepl/server)")] :p))

# XXX: the following can be used to arrange for the overriding of the
#      "test" phony target -- thanks to rduplain and bakpakin
(put (dyn :rules) "test" nil)
(phony "test" ["build"]
       (os/execute ["jg-verdict"
                    "-p" proj-root
                    "-s" src-root] :p))

(phony "judge" ["build"]
       (os/execute ["jg-verdict"
                    "-p" proj-root
                    "-s" src-root] :p))
