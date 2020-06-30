(declare-project
  :name "jff"
  :description "Janet Fuzzy Finder"
  :dependencies ["https://github.com/sepisoad/jtbox"
                 "https://github.com/crocket/janet-utf8.git"
                 "https://github.com/janet-lang/argparse.git"])

(declare-executable :name "jff" :entry "jff.janet" :install true)

(declare-source :source ["jff/"])
