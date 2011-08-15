require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require "erector/xml_widget"

module XmlWidgetSpec

  class Rss2Widget < Erector::XMLWidget

    tag "rss"
    tag "channel"
    tag "title"
    tag "description"
    tag "link"
    tag "lastBuildDate"
    tag "pubDate"
    tag "item"
    tag "guid"

    def content
      instruct
      rss(:version => "2.0") {
        channel {
          channel_content
        }
      }
    end

  end

  class SampleChannel < Rss2Widget
    def channel_content
      title do
        text 'RSS Title'
      end
      description 'This is an example of an RSS feed'
      link 'http://www.someexamplerssdomain.com/main.html'
      lastBuildDate 'Mon, 06 Sep 2010 00:01:00 +0000'
      pubDate 'Mon, 06 Sep 2009 16:45:00 +0000'
      item {
        title 'Example entry'
        description 'Here is some text containing an interesting description.'
        link 'http://www.wikipedia.org/'
        guid 'unique string per item'
        pubDate 'Mon, 06 Sep 2009 16:45:00 +0000'
      }
    end
  end

  describe Erector::XMLWidget do

    it "can be overriden for a plain XML doc" do
      SampleChannel.new.emit(:prettyprint => true).should == <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>RSS Title</title>
    <description>This is an example of an RSS feed</description>
    <link>http://www.someexamplerssdomain.com/main.html</link>
    <lastBuildDate>Mon, 06 Sep 2010 00:01:00 +0000</lastBuildDate>
    <pubDate>Mon, 06 Sep 2009 16:45:00 +0000</pubDate>
    <item>
      <title>Example entry</title>
      <description>Here is some text containing an interesting description.</description>
      <link>http://www.wikipedia.org/</link>
      <guid>unique string per item</guid>
      <pubDate>Mon, 06 Sep 2009 16:45:00 +0000</pubDate>
    </item>
  </channel>
</rss>
      XML
    end
  end
end

