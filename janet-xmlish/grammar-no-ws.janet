(import ./grammar :as g)

(def xmlish-peg
  (do
    (defn handle-non-empty-elt-no-ws
      [& args]
      # e.g. [["a" "href" "https://janet-lang.org"] "text" "a"]
      (def open-name (first (first args)))
      (def close-name (last args))
      (when (= open-name close-name)
        (def attrs (drop 1 (first args)))
        (def content (filter |(and (not= "" $)
                                   (if (string? $)
                                     (not= "" (string/trim $))
                                     true))
                             (tuple/slice args 1 -2)))
        #
        {:attrs (when (not= (length attrs) 0)
                  (table ;attrs))
         :content (when (not= (length content) 0)
                    content)
         :tag open-name}))
    #
    (def new-tbl
      (table/setproto
          ~@{:non-empty-elt
             (cmt (sequence :open-tag
                            (any (choice (capture :pcdata)
                                         :comment
                                         :elt
                                         (capture :content)))
                            :close-tag)
                  ,handle-non-empty-elt-no-ws)}
          g/xmlish-peg))
    #
    (table/proto-flatten new-tbl)))

(comment

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

  (peg/match xmlish-peg rss-feed)
  # =>
  @[{:content
     @[{:content
        @[{:content @["RSS Title"]
           :tag "title"}
          {:content @["This is an example of an RSS feed"]
           :tag "description"}
          {:content @["http://www.example.com/main.html"]
           :tag "link"}
          {:content @["Mon, 06 Sep 2010 00:01:00 +0000"]
           :tag "lastBuildDate"}
          {:content @["Sun, 06 Sep 2009 16:20:00 +0000"]
           :tag "pubDate"}
          {:content @["1800"]
           :tag "ttl"}
          {:content
           @[{:content @["Example entry"]
              :tag "title"}
             {:content
              @["A description."]
              :tag "description"}
             {:content @["http://www.example.com/blog/post/1"]
              :tag "link"}
             {:content @["7bd204c6-1655-4c27-aeee-53f933c5395f"]
              :tag "guid"
              :attrs @{"isPermaLink" "false"}}
             {:content @["Sun, 06 Sep 2009 16:20:00 +0000"]
              :tag "pubDate"}]
           :tag "item"}]
        :tag "channel"}]
     :tag "rss"
     :attrs @{"version" "2.0"}}]

  )

