(import ../janet-xmlish/grammar :prefix "")

(comment

  (peg/match
    xmlish-peg
    ``
    <html>
    <body>
    <a href="https://janet-lang.org/">Janet Home Page</a>
    </body>
    </html>
    ``)
  # =>
  @[{:content @["\n"
                {:content @["\n"
                            {:attrs @{"href" "https://janet-lang.org/"}
                             :content @["Janet Home Page"]
                             :tag "a"}
                            "\n"]
                 :tag "body"}
                "\n"]
     :tag "html"}]

  (peg/match
    xmlish-peg
    ``
    <!doctype html>
    <html>
    <body>
    <a href="https://janet-lang.org/">Janet Home Page</a>
    </body>
    </html>
    ``)
  # =>
  @[{:content @["\n"
                {:content @["\n"
                            {:attrs @{"href" "https://janet-lang.org/"}
                             :content @["Janet Home Page"]
                             :tag "a"}
                            "\n"]
                 :tag "body"}
                "\n"]
     :tag "html"}]

  (peg/match
    xmlish-peg
    ``
    <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
    <hi>hello</hi>
    ``)
  # =>
  @[{:content @["hello"] :tag "hi"}]

  (peg/match
    xmlish-peg
    ``
    <hi/>
    ``)
  # =>
  @[{:tag "hi"}]

  (peg/match xmlish-peg
             ``<hi a="1" b="2"/>``)
  # =>
  @[{:tag "hi"
     :attrs @{"a" "1" "b" "2"}}]

  (peg/match xmlish-peg
             ``<hi a="smile" b="breath" >hello</hi>``)
  # =>
  @[{:content @["hello"]
     :tag "hi"
     :attrs @{"a" "smile" "b" "breath"}}]

  (peg/match
    xmlish-peg
    ``
    <ho></ho>
    ``)
  # =>
  @[{:tag "ho"}]

  (peg/match xmlish-peg
             "<bye><hi>there</hi></bye>")
  # =>
  @[{:content @[{:content @["there"]
                 :tag "hi"}]
     :tag "bye"}]

  (peg/match xmlish-peg
             "<bye><hi>the<smile></smile>re</hi></bye>")
  # =>
  @[{:content @[{:content @["the"
                            {:tag "smile"}
                            "re"]
                 :tag "hi"}]
     :tag "bye"}]

  (peg/match
    xmlish-peg
    ``
    <hi>hello<bye></bye></hi>
    ``)
  # =>
  @[{:content @["hello" {:tag "bye"}]
     :tag "hi"}]

  (peg/match xmlish-peg "<a><a></a></a>")
  # =>
  @[{:content @[{:tag "a"}]
     :tag "a"}]

  (peg/match xmlish-peg ``<a b="0"><a c="8"></a></a>``)
  # =>
  @[{:content @[{:tag "a"
                 :attrs @{"c" "8"}}]
     :tag "a"
     :attrs @{"b" "0"}}]

  (peg/match
    xmlish-peg
    ``
    <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
    <a><!-- b --><c><!-- d --><e/></c></a>
    ``)
  # =>
  @[{:content @[{:content @[{:tag "e"}]
                 :tag "c"}]
     :tag "a"}]

  (peg/match
    xmlish-peg
    ``
    <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
    <oops>💩</oops>
    ``)
  # =>
  @[{:content @["\xF0\x9F\x92\xA9"]
     :tag "oops"}]

  )
