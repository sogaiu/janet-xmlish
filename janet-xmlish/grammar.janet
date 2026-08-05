# single def for easy copy-pasting
(def xmlish-peg
  (do
    (defn handle-empty-elt
      [& args]
      # e.g. ["img" "src" "https://janet-lang.org/assets/favicon.ico"]
      (def name (first args))
      (def attrs (drop 1 args))
      #
      {:attrs (when (not= (length attrs) 0)
                (table ;attrs))
       :tag name})
    #
    (defn handle-non-empty-elt
      [& args]
      # e.g. [["a" "href" "https://janet-lang.org"] "text" "a"]
      (def open-name (first (first args)))
      (def close-name (last args))
      (when (= open-name close-name)
        (def attrs (drop 1 (first args)))
        (def content (filter |(not= "" $)
                             (tuple/slice args 1 -2)))
        #
        {:attrs (when (not= (length attrs) 0)
                  (table ;attrs))
         :content (when (not= (length content) 0)
                    content)
         :tag open-name}))
    # see https://www.w3.org/TR/xml
    ~@{:main (sequence (opt (drop :xml-declaration)) :ws*
                       (opt (drop :doctype)) :ws*
                       (any :comment) :ws*
                       :elt :ws*
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
       :elt (choice :empty-elt :non-empty-elt)
       #
       :empty-elt (cmt (sequence
                         "<" (capture :name) :ws*
                         (any :attribute)
                         "/>")
                       ,handle-empty-elt)
       #
       :non-empty-elt (cmt (sequence :open-tag
                                     (any (choice (capture :pcdata)
                                                  :comment
                                                  :elt
                                                  (capture :content)))
                                     :close-tag)
                           ,handle-non-empty-elt)
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
       :content (to "<")}))

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

  (def rss-feed
    (string
      `<?xml version="1.0" encoding="UTF-8" standalone="no" ?>` "\n"
      `<rss version="2.0">` "\n"
      `<channel>` "\n"
      `<title>RSS Title</title>` "\n"
      `<description>This is an example of an RSS feed</description>` "\n"
      `<link>http://www.example.com/main.html</link>` "\n"
      `<lastBuildDate>Mon, 06 Sep 2010 00:01:00 +0000</lastBuildDate>` "\n"
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

  # pushing the bounds of reasonableness for expressing this way?
  (peg/match xmlish-peg rss-feed)
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
          {:content @["Mon, 06 Sep 2010 00:01:00 +0000"]
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

