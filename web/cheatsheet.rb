dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/navbar"

class Cheatsheet < Page
  def initialize
    super(:page_title => "Cheatsheet")
  end

  def promo
    "images/1959erector.jpeg"
  end

  def body_content
    h2.clear "Erector API Cheatsheet"
    
      cheats = [
        ["element('foo')",             "<foo></foo>"],
        ["empty_element('foo')",       "<foo />"],
        ["html",                       "<html></html>", "and likewise for all non-deprecated elements from the HTML 4.0.1 spec"],
        ["b 'foo'",                    "<b>foo</b>"],
        ["div { b 'foo' }",            "<div><b>foo</b></div>"],

        ["text 'foo'",                 "foo"],
        ["text '&<>'",                 "&amp;&lt;&gt;", "all normal text is HTML escaped, which is what you generally want, especially if the text came from the user or a database"],
        ["text raw('&<>')",            "&<>", "raw text escapes being escaped"],
        ["rawtext('&<>')",             "&<>", "alias for text(raw())"],
        ["text!('&<>')",               "&<>", "another alias for text(raw())"],

        ["div { text 'foo' }",        "<div>foo</div>"],
        ["div 'foo'",                 "<div>foo</div>"],
        ["foo = 'bar'\ndiv foo",      "<div>bar</div>"],
        ["a(:href => 'foo.div')",     "<a href=\"foo.div\"></a>"],
        ["a(:href => 'q?a&b')",        "<a href=\"q?a&amp;b\"></a>", "attributes are escaped like text is"],
        ["a(:href => raw('&amp;'))",   "<a href=\"&amp;\"></a>", "raw strings are never escaped, even in attributes"],
        ["a 'foo', :href => \"bar\"",    "<a href=\"bar\">foo</a>"],

        ["text nbsp('Save Doc')",      "Save&#160;Doc", "turns spaces into non-breaking spaces"],
        ["text nbsp",                  "&#160;", "a single non-breaking space"],
        ["text character(160)",        "&#xa0;", "output a character given its unicode code point"],
        ["text character(:right-arrow)",      "&#x2192;", "output a character given its unicode name"],

        ["instruct",                   "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"],
        ["comment 'foo'",              "<!--foo-->"],
        ["url 'http://example.com'",   "<a href=\"http://example.com\">http://example.com</a>"],

        ["capture { div }", "<div></div>", "returns the block as a string, doesn't add it to the current output stream"],
        ["div :class => ['a', 'b']", "<div class=\"a b\"></div>"],
      ]
      cheats << [
        "javascript(\n" +
        "'if (x < y && x > z) \n" +
        'alert("don\'t stop");' +
        ')', <<-DONE
<script type="text/javascript">
// <![CDATA[
if (x < y && x > z) alert("don't stop");
// ]]>
</script>
DONE
        ]
      cheats << [
        "jquery '$(\"p\").wrap(\"<div></div>\");'",
<<-DONE
<script type="text/javascript">
// <![CDATA[
jQuery(document).ready(function($){
  $("p").wrap("<div></div>");
});
// ]]>
</script>
DONE
        ]

      cheats << ["join([widget1, widget2],\n separator)", "", "See examples/join.rb for more explanation"]

      table :class => 'cheatsheet' do
        tr do
          th "code"
          th "output"
        end
        cheats.each do |cheat|
          tr do
            td :width=>"30%" do
              code do
                join cheat[0].split("\n"), raw("<br/>")
              end
            end
            td do
              if cheat[1]
                code do
                  join cheat[1].split("\n"), raw("<br/>")
                end
              end
              if cheat[2]
                text nbsp("  ")
                text character(:horizontal_ellipsis)
                i cheat[2]
              end
            end
          end
        end
      end

      p do
        text "Lots more documentation is at the "
        a "RDoc API pages", :href => "rdoc/index.html"
        text " especially for "
        a "Erector::Widget", :href => "rdoc/classes/Erector/Widget.html"
        text " so don't go saying we never wrote you nothin'."
      end
    end
end
