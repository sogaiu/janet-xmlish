# https://www.w3.org/TR/xml
(def xmlish-peg
  ~{:main (sequence (opt (drop :xml-declaration))
                    (opt (drop :doctype))
                    (any :comment)
                    :element
                    (any :comment))
    #
    :xml-declaration (sequence
                      :s* "<?xml" :s*
                      (any :attribute) :s*
                      "?>" :s*)
    # XXX: only handles very simple case
    :doctype (sequence
               :s* "<!doctype" :s*
               :tag-name :s*
               ">" :s*)
    # XXX: not accurate
    :attribute (sequence
                (capture (to (set " /<=>\""))) :s*
                "=" :s*
                (choice (sequence `"` (capture (to `"`)) `"`)
                        (sequence "'" (capture (to "'")) "'"))
                :s*)
    # section 2.5 of xml spec
    :comment (sequence
              "<!--"
              (any (choice
                    (if-not (set "-") 1)
                    (sequence "-" (if-not (set "-") 1))))
              "-->" :s*)
    #
    :element (choice :empty-element :non-empty-element)
    #
    :empty-element (cmt (sequence
                         "<" (capture :tag-name) :s*
                         (any :attribute)
                         "/>")
                        ,|(let [args $&
                                elt-name (first args)
                                attrs (drop 1 args)
                                attrs (if (= (length attrs) 0)
                                        nil
                                        (table ;attrs))]
                            {:attrs attrs
                             :tag elt-name}))
    # XXX: not accurate
    :tag-name (to (set " /<>"))
    #
    :non-empty-element (cmt (sequence
                             :open-tag
                             (any
                              (choice :comment :element (capture :pcdata)))
                             :close-tag)
                            ,|(let [args $&
                                    open-name (first (first args))
                                    attrs (drop 1 (first args))
                                    close-name (last args)]
                                (when (= open-name close-name)
                                  (let [elt-name open-name
                                        content (filter (fn [c-item]
                                                          (not= "" c-item))
                                                        (tuple/slice args 1 -2))
                                        content (if (= (length content) 0)
                                                  nil
                                                  content)
                                        attrs (if (= (length attrs) 0)
                                                nil
                                                (table ;attrs))]
                                    {:attrs attrs
                                     :content content
                                     :tag elt-name}))))
    #
    :open-tag (group
               (sequence
                "<" (capture :tag-name) :s*
                (any :attribute)
                ">"))
    # XXX: not accurate
    :pcdata (to (set "<>"))
    #
    :close-tag (sequence
                "</" (capture :tag-name) :s* ">")})

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
    <?xml version='1.0' encoding="utf-8"?>
    <some>
      <xml>
      here
      </xml>
    </some>
    ``)
  # =>
  @[{:content @["\n  "
                {:content @["\n  here\n  "]
                 :tag "xml"}
                "\n"]
     :tag "some"}]

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

  # pushing the bounds of reasonableness for expressing this way?
  (peg/match
    xmlish-peg
    ``
    <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
    <rss version="2.0">
    <channel>
      <title>RSS Title</title>
      <description>This is an example of an RSS feed</description>
      <link>http://www.example.com/main.html</link>
      <lastBuildDate>Mon, 06 Sep 2010 00:01:00 +0000 </lastBuildDate>
      <pubDate>Sun, 06 Sep 2009 16:20:00 +0000</pubDate>
      <ttl>1800</ttl>
      <item>
        <title>Example entry</title>
        <description>Here is some text containing an interesting description.</description>
        <link>http://www.example.com/blog/post/1</link>
        <guid isPermaLink="false">7bd204c6-1655-4c27-aeee-53f933c5395f</guid>
        <pubDate>Sun, 06 Sep 2009 16:20:00 +0000</pubDate>
      </item>
    </channel>
    </rss>
    ``)
  # =>
  @[{:content
     @["\n"
       {:content
        @["\n  "
          {:content @["RSS Title"]
           :tag "title"}
          "\n  "
          {:content @["This is an example of an RSS feed"]
           :tag "description"}
          "\n  "
          {:content @["http://www.example.com/main.html"]
           :tag "link"}
          "\n  "
          {:content @["Mon, 06 Sep 2010 00:01:00 +0000 "]
           :tag "lastBuildDate"}
          "\n  "
          {:content @["Sun, 06 Sep 2009 16:20:00 +0000"]
           :tag "pubDate"}
          "\n  "
          {:content @["1800"]
           :tag "ttl"}
          "\n  "
          {:content
           @["\n    "
             {:content @["Example entry"]
              :tag "title"}
             "\n    "
             {:content
              @["Here is some text containing an interesting description."]
              :tag "description"}
             "\n    "
             {:content @["http://www.example.com/blog/post/1"]
              :tag "link"}
             "\n    "
             {:content @["7bd204c6-1655-4c27-aeee-53f933c5395f"]
              :tag "guid"
              :attrs @{"isPermaLink" "false"}}
             "\n    "
             {:content @["Sun, 06 Sep 2009 16:20:00 +0000"]
              :tag "pubDate"}
             "\n  "]
           :tag "item"}
          "\n"]
        :tag "channel"}
       "\n"]
     :tag "rss"
     :attrs @{"version" "2.0"}}]

)
