(import ../janet-xmlish/grammar :prefix "")

(comment

  (peg/match
    xmlish-peg
    (string `<html>` "\n"
            `<body>` "\n"
            `<a href="https://janet-lang.org/">Janet Home Page</a>` "\n"
            `</body>` "\n"
            `</html>`))
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
    (string `<!DOCTYPE html>` "\n"
            `<html>` "\n"
            `<body>` "\n"
            `<a href="https://janet-lang.org/">Janet Home Page</a>` "\n"
            `</body>` "\n"
            `</html>`))
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
    (string `<?xml version="1.0" encoding="UTF-8" standalone="no" ?>` "\n"
            "<hi>hello</hi>"))
  # =>
  @[{:content @["hello"] :tag "hi"}]

  (peg/match xmlish-peg "<hi/>")
  # =>
  @[{:tag "hi"}]

  (peg/match xmlish-peg `<hi a="1" b="2"/>`)
  # =>
  @[{:tag "hi"
     :attrs @{"a" "1" "b" "2"}}]

  (peg/match xmlish-peg `<hi a="smile" b="breath" >hello</hi>`)
  # =>
  @[{:content @["hello"]
     :tag "hi"
     :attrs @{"a" "smile" "b" "breath"}}]

  (peg/match xmlish-peg "<ho></ho>")
  # =>
  @[{:tag "ho"}]

  (peg/match xmlish-peg "<bye><hi>there</hi></bye>")
  # =>
  @[{:content @[{:content @["there"]
                 :tag "hi"}]
     :tag "bye"}]

  (peg/match xmlish-peg "<bye><hi>the<smile></smile>re</hi></bye>")
  # =>
  @[{:content @[{:content @["the"
                            {:tag "smile"}
                            "re"]
                 :tag "hi"}]
     :tag "bye"}]

  (peg/match xmlish-peg "<hi>hello<bye></bye></hi>")
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
    (string `<?xml version="1.0" encoding="UTF-8" standalone="no" ?>` "\n"
            "<a><!-- b --><c><!-- d --><e/></c></a>"))
  # =>
  @[{:content @[{:content @[{:tag "e"}]
                 :tag "c"}]
     :tag "a"}]

  (peg/match
    xmlish-peg
    (string `<?xml version="1.0" encoding="UTF-8" standalone="no" ?>` "\n"
            "<oops>💩</oops>"))
  # =>
  @[{:content @["\xF0\x9F\x92\xA9"]
     :tag "oops"}]

  )

(comment

  (def feed
    ``
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <title>Lobsters</title>
        <link>https://lobste.rs/</link>
        <atom:link href="https://lobste.rs/rss" rel="self"/>
        <description></description>
        <pubDate>Wed, 04 Feb 2026 13:20:32 -0600</pubDate>
        <ttl>120</ttl>
        <item>
          <title>Recreating PDFs</title>
          <link>https://neosmart.net/blog/</link>
          <guid>https://lobste.rs/s/iyu0f8</guid>
          <author>neosmart.net by mqudsi</author>
          <pubDate>Wed, 04 Feb 2026 13:20:32 -0600</pubDate>
          <comments>https://lobste.rs/s/iyu0f8/recreating</comments>
          <description>&lt;p&gt;&lt;a href="https://lobste.rs/s/2svv99/competence_as_tragedy"&gt;Comments&lt;/a&gt;&lt;/p&gt;</description>
          <category>security</category>
          <category>reversing</category>
        </item>
      </channel>
    </rss>
    ``)

  (peg/match xmlish-peg feed)
  # =>
@[{:attrs @{"version" "2.0"
            "xmlns:atom" "http://www.w3.org/2005/Atom"}
   :content
   @["\n  "
     {:content
      @["\n    "
        {:content @["Lobsters"]
         :tag "title"}
        "\n    "
        {:content @["https://lobste.rs/"]
         :tag "link"}
        "\n    "
        {:attrs @{"href" "https://lobste.rs/rss"
                  "rel" "self"}
         :tag "atom:link"}
        "\n    "
        {:tag "description"}
        "\n    "
        {:content @["Wed, 04 Feb 2026 13:20:32 -0600"]
         :tag "pubDate"}
        "\n    "
        {:content @["120"]
         :tag "ttl"}
        "\n    "
        {:content
         @["\n      "
           {:content @["Recreating PDFs"]
            :tag "title"}
           "\n      "
           {:content @["https://neosmart.net/blog/"]
            :tag "link"}
           "\n      "
           {:content @["https://lobste.rs/s/iyu0f8"]
            :tag "guid"}
           "\n      "
           {:content @["neosmart.net by mqudsi"]
            :tag "author"}
           "\n      "
           {:content @["Wed, 04 Feb 2026 13:20:32 -0600"]
            :tag "pubDate"}
           "\n      "
           {:content @["https://lobste.rs/s/iyu0f8/recreating"]
            :tag "comments"}
           "\n      "
           {:content
            @[(string "&lt;p&gt;&lt;a href=\"https://lobste.rs/s/"
                      "2svv99/competence_as_tragedy\"&gt;Comments&lt;"
                      "/a&gt;&lt;/p&gt;")]
            :tag "description"}
           "\n      "
           {:content @["security"]
            :tag "category"}
           "\n      "
           {:content @["reversing"]
            :tag "category"}
           "\n    "]
         :tag "item"}
        "\n  "]
      :tag "channel"}
     "\n"]
   :tag "rss"}]

  (peg/match xmlish-peg "<rss>\n</rss>")
  # =>
  @[{:content @["\n"]
     :tag "rss"}]

  (def feed-1
    ``
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0"><description><![CDATA[a]]></description></rss>
    ``)

  (peg/match xmlish-peg feed-1)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content @[{:content @["<![CDATA[a]]>"] :tag "description"}]
     :tag "rss"}]

  (def feed-2
    ``
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0"><description><![CDATA[<a href="https://news.ycombinator.com/item?id=46895972">Comments</a>]]></description></rss>
    ``)

  (peg/match xmlish-peg feed-2)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content
     @[{:content
        @[(string "<![CDATA[<a href=\""
                  "https://news.ycombinator.com/item?id=46895972"
                  "\">Comments</a>]]>")]
        :tag "description"}]
     :tag "rss"}]

  (def feed-3
    ``
    <rss version="2.0"><description><![CDATA[<a href="https://news.ycombinator.com/item?id=46895972">Comments</a>]]></description></rss>
    ``)

  (peg/match xmlish-peg feed-3)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content
     @[{:content @[(string "<![CDATA[<a href=\""
                           "https://news.ycombinator.com/item?id=46895972"
                           "\">Comments</a>]]>")]
        :tag "description"}]
     :tag "rss"}]

  (def feed-4
    ``
    <rss version="2.0"><channel><description><![CDATA[<a href="https://news.ycombinator.com/item?id=46895972">Comments</a>]]></description></channel></rss>
    ``)

  (peg/match xmlish-peg feed-4)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content
     @[{:content
        @[{:content
           @[(string "<![CDATA[<a href=\""
                     "https://news.ycombinator.com/item?id=46895972"
                     "\">Comments</a>]]>")]
           :tag "description"}]
        :tag "channel"}]
     :tag "rss"}]

  (def feed-5
    ``
    <rss version="2.0"><channel><description><![CDATA[<a href="https://news.ycombinator.com/item?id=46895972">Comments</a>]]></description><item></item></channel></rss>
    ``)

  (peg/match xmlish-peg feed-5)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content
     @[{:content
        @[{:content
           @[(string "<![CDATA[<a href=\""
                     "https://news.ycombinator.com/item?id=46895972"
                     "\">Comments</a>]]>")]
           :tag "description"}
          {:tag "item"}]
        :tag "channel"}]
     :tag "rss"}]

  (def feed-6
    ``
    <rss version="2.0"><channel><title>Hacker News</title><link>https://news.ycombinator.com/</link><description>Links for the intellectually curious, ranked by readers.</description><item></item></channel></rss>
    ``)

  (peg/match xmlish-peg feed-6)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content
     @[{:content
        @[{:content @["Hacker News"] :tag "title"}
          {:content @["https://news.ycombinator.com/"] :tag "link"}
          {:content @["Links for the intellectually curious, ranked by readers."]
           :tag "description"}
          {:tag "item"}]
        :tag "channel"}]
     :tag "rss"}]

  (def feed-7
    ``
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0"><description><![CDATA[<a href="https://news.ycombinator.com/item?id=46895972">Comments</a>]]></description></rss>
    ``)

  (peg/match xmlish-peg feed-7)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content
     @[{:content
        @[(string "<![CDATA[<a href=\""
                  "https://news.ycombinator.com/item?id=46895972"
                  "\">Comments</a>]]>")]
        :tag "description"}]
     :tag "rss"}]

  (def feed-8
    ``
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
<description><![CDATA[<a href="https://news.ycombinator.com/item?id=46895972">Comments</a>]]></description></rss>
    ``)

  (peg/match xmlish-peg feed-8)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content
     @["\n"
       {:content
        @[(string "<![CDATA[<a href=\""
                  "https://news.ycombinator.com/item?id=46895972"
                  "\">Comments</a>]]>")]
        :tag "description"}]
     :tag "rss"}]

  (def feed-9
    ``
    <rss version="2.0">
<description><![CDATA[<a href="https://news.ycombinator.com/item?id=46895972">Comments</a>]]></description></rss>
    ``)

  (peg/match xmlish-peg feed-9)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content
     @["\n"
       {:content
        @[(string "<![CDATA[<a href=\""
                  "https://news.ycombinator.com/item?id=46895972"
                  "\">Comments</a>]]>")]
        :tag "description"}]
     :tag "rss"}]

  (def feed-10
    ``
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0"><channel><title>Hacker News</title><link>https://news.ycombinator.com/</link><description>Links for the intellectually curious, ranked by readers.</description><item><title>When internal hostnames are leaked to the clown</title><link>https://rachelbythebay.com/w/2026/02/03/badnas/</link><pubDate>Thu, 05 Feb 2026 05:22:36 +0000</pubDate><comments>https://news.ycombinator.com/item?id=46895972</comments><description><![CDATA[<a href="https://news.ycombinator.com/item?id=46895972">Comments</a>]]></description></item></channel></rss>
    ``)

  (peg/match xmlish-peg feed-10)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content
     @[{:content
        @[{:content
           @["Hacker News"]
           :tag "title"}
          {:content @["https://news.ycombinator.com/"]
           :tag "link"}
          {:content @["Links for the intellectually curious, ranked by readers."]
           :tag "description"}
          {:content
           @[{:content @["When internal hostnames are leaked to the clown"]
              :tag "title"}
             {:content @["https://rachelbythebay.com/w/2026/02/03/badnas/"]
              :tag "link"}
             {:content @["Thu, 05 Feb 2026 05:22:36 +0000"]
              :tag "pubDate"}
             {:content @["https://news.ycombinator.com/item?id=46895972"]
              :tag "comments"}
             {:content @[(string "<![CDATA[<a href=\""
                                 "https://news.ycombinator.com/item?id=46895972"
                                 "\">Comments</a>]]>")]
              :tag "description"}]
           :tag "item"}]
        :tag "channel"}]
     :tag "rss"}]

  (def feed-11
    ``
    <rss version="2.0"><channel><title>Hacker News</title><link>https://news.ycombinator.com/</link><description>Links for the intellectually curious, ranked by readers.</description><item><title>When internal hostnames are leaked to the clown</title><link>https://rachelbythebay.com/w/2026/02/03/badnas/</link><pubDate>Thu, 05 Feb 2026 05:22:36 +0000</pubDate><comments>https://news.ycombinator.com/item?id=46895972</comments><description><![CDATA[<a href="https://news.ycombinator.com/item?id=46895972">Comments</a>]]></description></item></channel></rss>
    ``)

  (peg/match xmlish-peg feed-11)
  # =>
  @[{:attrs @{"version" "2.0"}
     :content
     @[{:content
        @[{:content @["Hacker News"] :tag "title"}
          {:content @["https://news.ycombinator.com/"] :tag "link"}
          {:content @["Links for the intellectually curious, ranked by readers."]
           :tag "description"}
          {:content
           @[{:content @["When internal hostnames are leaked to the clown"]
              :tag "title"}
             {:content @["https://rachelbythebay.com/w/2026/02/03/badnas/"]
              :tag "link"}
             {:content @["Thu, 05 Feb 2026 05:22:36 +0000"]
              :tag "pubDate"}
             {:content @["https://news.ycombinator.com/item?id=46895972"]
              :tag "comments"}
             {:content @[(string "<![CDATA[<a href=\""
                                 "https://news.ycombinator.com/item?id=46895972"
                                 "\">Comments</a>]]>")]
              :tag "description"}]
           :tag "item"}]
        :tag "channel"}]
     :tag "rss"}]

  )

