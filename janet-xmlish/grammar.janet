# https://www.w3.org/TR/xml
(def xmlish-peg
  ~{:main (sequence (opt (drop :xml-declaration)) :ws*
                    (opt (drop :doctype)) :ws*
                    (any :comment) :ws*
                    :element :ws*
                    (any :comment) :ws*)
    # XXX: see spec for whitespace details
    :xml-declaration (sequence :ws* "<?xml" :ws*
                               (any :attribute) :ws*
                               "?>")
    # section 2.3 of xml spec
    :ws (set " \t\r\n")
    :ws+ (some :ws)
    :ws* (any :ws)
    # XXX: does not handle internal subset, see section 2.8 of xml spec
    :doctype (sequence :ws* "<!" (choice "DOCTYPE" "doctype") :ws+
                       :name (opt (sequence :ws+ :external-id)) :ws*
                       ">")
    # section 4.2.2 of xml spec
    :external-id
    (choice (sequence "SYSTEM" :ws+ :system-literal)
            (sequence "PUBLIC" :ws+ :pubid-literal :ws+ :system-literal))
    # section 2.3 of xml spec
    :system-literal (choice (sequence `"` (capture (to `"`)) `"`)
                            (sequence "'" (capture (to "'")) "'"))
    :pubid-literal (choice (sequence `"` (any :pubid-char) `"`)
                           (sequence "'" (any :pubid-char-wo-quote) "'"))
    :pubid-char (choice :pubid-char-wo-quote "'")
    :pubid-char-wo-quote (choice :w (set ` \r\n-()+,./:=?;!*#@$_%`))
    # XXX: not accurate, see section 3.1 of xml spec
    :attribute (sequence
                (capture (to (set " /<=>\""))) :ws*
                "=" :ws*
                (choice (sequence `"` (capture (to `"`)) `"`)
                        (sequence "'" (capture (to "'")) "'"))
                :ws*)
    # section 2.5 of xml spec
    :comment (sequence
              "<!--"
              (any (choice
                    (if-not (set "-") 1)
                    (sequence "-" (if-not (set "-") 1))))
              "-->")
    #
    :element (choice :empty-element :non-empty-element)
    #
    :empty-element (cmt (sequence
                         "<" (capture :name) :ws*
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
    #
    :non-empty-element
    (cmt (sequence :open-tag
                   (any (choice (capture :pcdata)
                                :comment
                                :element
                                (capture :content)
                                ))
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
    # XXX: this is a hack, see section 2.3 of xml spec
    :name (sequence (not "!") (not "?") (to (set " /<>")))
    #
    :open-tag (group
                (sequence
                  "<" (capture :name) :ws*
                  (any :attribute)
                  ">"))
    #
    :close-tag (sequence
                 "</" (capture :name) :ws* ">")
    # XXX: may not be accurate
    :pcdata (sequence "<![CDATA[" (to "]]>") "]]>")
    # XXX: may not be accurate
    :content (to "<")})

(comment

  (peg/match
    xmlish-peg
    (string
      `<?xml version='1.0' encoding="utf-8"?>` "\n"
      `<some>`                                 "\n"
      `  <xml>`                                "\n"
      `  here`                                 "\n"
      `  </xml>`                               "\n"
      `</some>`))
  # =>
  @[{:content @["\n  "
                {:content @["\n  here\n  "]
                 :tag "xml"}
                "\n"]
     :tag "some"}]

  # pushing the bounds of reasonableness for expressing this way?
  (peg/match
    xmlish-peg
    (string
      `<?xml version="1.0" encoding="UTF-8" standalone="no" ?>` "\n"
      `<rss version="2.0">` "\n"
      `<channel>` "\n"
      `<title>RSS Title</title>` "\n"
      `<description>This is an example of an RSS feed</description>` "\n"
      `<link>http://www.example.com/main.html</link>` "\n"
      `<lastBuildDate>Mon, 06 Sep 2010 00:01:00 +0000 </lastBuildDate>` "\n"
      `<pubDate>Sun, 06 Sep 2009 16:20:00 +0000</pubDate>` "\n"
      `<ttl>1800</ttl>` "\n"
      `<item>` "\n"
      `  <title>Example entry</title>` "\n"
      `  <description>A description.</description>` "\n"
      `  <link>http://www.example.com/blog/post/1</link>` "\n"
      `  <guid isPermaLink="false">7bd204c6-1655-4c27-aeee-53f933c5395f</guid>` "\n"
      `  <pubDate>Sun, 06 Sep 2009 16:20:00 +0000</pubDate>` "\n"
      `  </item>` "\n"
      `</channel>` "\n"
      `</rss>`))
  # =>
  @[{:content
     @["\n"
       {:content
        @["\n"
          {:content @["RSS Title"]
           :tag "title"}
          "\n"
          {:content @["This is an example of an RSS feed"]
           :tag "description"}
          "\n"
          {:content @["http://www.example.com/main.html"]
           :tag "link"}
          "\n"
          {:content @["Mon, 06 Sep 2010 00:01:00 +0000 "]
           :tag "lastBuildDate"}
          "\n"
          {:content @["Sun, 06 Sep 2009 16:20:00 +0000"]
           :tag "pubDate"}
          "\n"
          {:content @["1800"]
           :tag "ttl"}
          "\n"
          {:content
           @["\n  "
             {:content @["Example entry"]
              :tag "title"}
             "\n  "
             {:content
              @["A description."]
              :tag "description"}
             "\n  "
             {:content @["http://www.example.com/blog/post/1"]
              :tag "link"}
             "\n  "
             {:content @["7bd204c6-1655-4c27-aeee-53f933c5395f"]
              :tag "guid"
              :attrs @{"isPermaLink" "false"}}
             "\n  "
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

