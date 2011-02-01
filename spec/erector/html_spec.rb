require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::HTML do
  include Erector::Mixin

  describe ".all_tags" do
    it "returns set of full and empty tags" do
      Erector::Widget.all_tags.class.should == Array
      Erector::Widget.all_tags.should == Erector::Widget.full_tags + Erector::Widget.empty_tags
    end
  end

  describe "#instruct" do
    it "when passed no arguments; returns an XML declaration with version 1 and utf-8" do
      # version must precede encoding, per XML 1.0 4th edition (section 2.8)
      erector { instruct }.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    end
  end

  describe "#element" do
    context "when receiving one argument" do
      it "returns an empty element" do
        erector { element('div') }.should == "<div></div>"
      end
    end

    context "with a attribute hash" do
      it "returns an empty element with the attributes" do
        html = erector do
          element(
            'div',
            :class => "foo bar",
            :style => "display: none; color: white; float: left;",
            :nil_attribute => nil
          )
        end
        doc = Nokogiri::HTML(html)
        div = doc.at('div')
        div[:class].should == "foo bar"
        div[:style].should == "display: none; color: white; float: left;"
        div[:nil_attribute].should be_nil
      end
    end

    context "with an array of CSS classes" do
      it "returns a tag with the classes separated" do
        erector do
          element('div', :class => [:foo, :bar])
        end.should == "<div class=\"foo bar\"></div>";
      end
    end

    context "with an array of CSS classes as strings" do
      it "returns a tag with the classes separated" do
        erector do
          element('div', :class => ['foo', 'bar'])
        end.should == "<div class=\"foo bar\"></div>";
      end
    end

    context "with a CSS class which is a string" do
      it "just use that as the attribute value" do
        erector do
          element('div', :class => "foo bar")
        end.should == "<div class=\"foo bar\"></div>";
      end
    end

    context "with an empty array of CSS classes" do
      it "does not emit a class attribute" do
        erector do
          element('div', :class => [])
        end.should == "<div></div>"
      end
    end

    context "with many attributes" do
      it "alphabetize them" do
        erector do
          empty_element('foo', :alpha => "", :betty => "5", :aardvark => "tough",
                        :carol => "", :demon => "", :erector => "", :pi => "3.14", :omicron => "", :zebra => "", :brain => "")
        end.should == "<foo aardvark=\"tough\" alpha=\"\" betty=\"5\" brain=\"\" carol=\"\" demon=\"\" " \
               "erector=\"\" omicron=\"\" pi=\"3.14\" zebra=\"\" />";
      end
    end

    context "with inner tags" do
      it "returns nested tags" do
        erector do
          element 'div' do
            element 'div'
          end
        end.should == '<div><div></div></div>'
      end
    end

    context "with text" do
      it "returns element with inner text" do
        erector do
          element 'div', 'test text'
        end.should == "<div>test text</div>"
      end
    end

    context "with a widget" do
      it "renders the widget inside the element" do
        erector do
          element 'div', Erector.inline { p "foo" }
        end.should == '<div><p>foo</p></div>'
      end
    end

    context "with object other than hash" do
      it "returns element with inner text == object.to_s" do
        object = ['a', 'b']
        erector do
          element 'div', object
        end.should == "<div>#{CGI.escapeHTML object.to_s}</div>"
      end
    end

    context "with parameters and block" do
      it "returns element with inner html and attributes" do
        erector do
          element 'div', 'class' => "foobar" do
            element 'span', 'style' => 'display: none;'
          end
        end.should == '<div class="foobar"><span style="display: none;"></span></div>'
      end
    end

    context "with content and parameters" do
      it "returns element with content as inner html and attributes" do
        erector do
          element 'div', 'test text', :style => "display: none;"
        end.should == '<div style="display: none;">test text</div>'
      end
    end

    context "with more than three arguments" do
      it "raises ArgumentError" do
        proc do
          erector do
            element 'div', 'foobar', {}, 'fourth'
          end
        end.should raise_error(ArgumentError)
      end
    end

    it "renders the proper full tags" do
      Erector::Widget.full_tags.each do |tag_name|
        expected = "<#{tag_name}></#{tag_name}>"
        actual = erector { send(tag_name) }
        begin
          actual.should == expected
        rescue Spec::Expectations::ExpectationNotMetError => e
          puts "Expected #{tag_name} to be a full element. Expected #{expected}, got #{actual}"
          raise e
        end
      end
    end

    describe "quoting" do
      context "when outputting text" do
        it "quotes it" do
          erector do
            element 'div', 'test &<>text'
          end.should == "<div>test &amp;&lt;&gt;text</div>"
        end
      end

      context "when outputting text via text" do
        it "quotes it" do
          erector do
            element 'div' do
              text "test &<>text"
            end
          end.should == "<div>test &amp;&lt;&gt;text</div>"
        end
      end

      context "when outputting attribute value" do
        it "quotes it" do
          erector do
            element 'a', :href => "foo.cgi?a&b"
          end.should == "<a href=\"foo.cgi?a&amp;b\"></a>"
        end
      end

      context "with raw text" do
        it "does not quote it" do
          erector do
            element 'div' do
              text raw("<b>bold</b>")
            end
          end.should == "<div><b>bold</b></div>"
        end
      end

      context "with raw text and no block" do
        it "does not quote it" do
          erector do
            element 'div', raw("<b>bold</b>")
          end.should == "<div><b>bold</b></div>"
        end
      end

      context "with raw attribute" do
        it "does not quote it" do
          erector do
            element 'a', :href => raw("foo?x=&nbsp;")
          end.should == "<a href=\"foo?x=&nbsp;\"></a>"
        end
      end

      context "with quote in attribute" do
        it "quotes it" do
          erector do
            element 'a', :onload => "alert(\"foo\")"
          end.should == "<a onload=\"alert(&quot;foo&quot;)\"></a>"
        end
      end
    end

    context "with a non-string, non-raw" do
      it "calls to_s and quotes" do
        array = [7, "foo&bar"]
        erector do
          element 'a' do
            text array
          end
        end.should == "<a>#{CGI.escapeHTML array.to_s}</a>"
      end
    end
  end

  describe "#empty_element" do
    context "when receiving attributes" do
      it "renders an empty element with the attributes" do
        erector do
          empty_element 'input', :name => 'foo[bar]'
        end.should == '<input name="foo[bar]" />'
      end
    end

    context "when not receiving attributes" do
      it "renders an empty element without attributes" do
        erector do
          empty_element 'br'
        end.should == '<br />'
      end
    end

    it "renders the proper empty-element tags" do
      Erector::Widget.empty_tags.each do |tag_name|
        expected = "<#{tag_name} />"
        actual = erector { send(tag_name) }
        begin
          actual.should == expected
        rescue Spec::Expectations::ExpectationNotMetError => e
          puts "Expected #{tag_name} to be an empty-element tag. Expected #{expected}, got #{actual}"
          raise e
        end
      end
    end
  end

  describe "#comment" do
    it "emits a single line comment when receiving a string" do
      erector do
        comment "foo"
      end.should == "<!--foo-->\n"
    end

    it "emits a multiline comment when receiving a block" do
      erector do
        comment do
          text "Hello"
          text " world!"
        end
      end.should == "<!--\nHello world!\n-->\n"
    end

    it "emits a multiline comment when receiving a string and a block" do
      erector do
        comment "Hello" do
          text " world!"
        end
      end.should == "<!--Hello\n world!\n-->\n"
    end

    # see http://www.w3.org/TR/html4/intro/sgmltut.html#h-3.2.4
    it "does not HTML-escape character references" do
      erector do
        comment "&nbsp;"
      end.should == "<!--&nbsp;-->\n"
    end

    # see http://www.w3.org/TR/html4/intro/sgmltut.html#h-3.2.4
    # "Authors should avoid putting two or more adjacent hyphens inside comments."
    it "warns if there's two hyphens in a row" do
      capturing_output do
        erector do
          comment "he was -- awesome!"
        end.should == "<!--he was -- awesome!-->\n"
      end.should == "Warning: Authors should avoid putting two or more adjacent hyphens inside comments.\n"
    end

    it "renders an IE conditional comment with endif when receiving an if IE" do
      erector do
        comment "[if IE]" do
          text "Hello IE!"
        end
      end.should == "<!--[if IE]>\nHello IE!\n<![endif]-->\n"
    end

    it "doesn't render an IE conditional comment if there's just some text in brackets" do
      erector do
        comment "[puppies are cute]"
      end.should == "<!--[puppies are cute]-->\n"
    end

  end

  describe "#nbsp" do
    it "turns consecutive spaces into consecutive non-breaking spaces" do
      erector do
        text nbsp("a  b")
      end.should == "a&#160;&#160;b"
    end

    it "works in text context" do
      erector do
        element 'a' do
          text nbsp("&<> foo")
        end
      end.should == "<a>&amp;&lt;&gt;&#160;foo</a>"
    end

    it "works in attribute value context" do
      erector do
        element 'a', :href => nbsp("&<> foo")
      end.should == "<a href=\"&amp;&lt;&gt;&#160;foo\"></a>"
    end

    it "defaults to a single non-breaking space if given no argument" do
      erector do
        text nbsp
      end.should == "&#160;"
    end

  end

  describe "#character" do
    it "renders a character given the codepoint number" do
      erector do
        text character(160)
      end.should == "&#xa0;"
    end

    it "renders a character given the unicode name" do
      erector do
        text character(:right_arrow)
      end.should == "&#x2192;"
    end

    it "renders a character above 0xffff" do
      erector do
        text character(:old_persian_sign_ka)
      end.should == "&#x103a3;"
    end

    it "throws an exception if a name is not recognized" do
      lambda {
        erector { text character(:no_such_character_name) }
      }.should raise_error("Unrecognized character no_such_character_name")
    end

    it "throws an exception if passed something besides a symbol or integer" do
      # Perhaps calling to_s would be more ruby-esque, but that seems like it might
      # be pretty confusing when this method can already take either a name or number
      lambda {
        erector { text character([]) }
      }.should raise_error("Unrecognized argument to character: #{[].to_s}")
    end
  end

  describe '#h' do
    before do
      @widget = Erector::Widget.new
    end

    it "escapes regular strings" do
      @widget.h("&").should == "&amp;"
    end

    it "does not escape raw strings" do
      @widget.h(@widget.raw("&")).should == "&"
    end
  end

  describe 'escaping' do
    plain = 'if (x < y && x > z) alert("don\'t stop");'
    escaped = "if (x &lt; y &amp;&amp; x &gt; z) alert(&quot;don't stop&quot;);"

    describe "#text" do
      it "does HTML escape its param" do
        erector { text plain }.should == escaped
      end

      it "doesn't escape pre-escaped strings" do
        erector { text h(plain) }.should == escaped
      end
    end
    describe "#rawtext" do
      it "doesn't HTML escape its param" do
        erector { rawtext plain }.should == plain
      end
    end
    describe "#text!" do
      it "doesn't HTML escape its param" do
        erector { text! plain }.should == plain
      end
    end
    describe "#element" do
      it "does HTML escape its param" do
        erector { element "foo", plain }.should == "<foo>#{escaped}</foo>"
      end
    end
    describe "#element!" do
      it "doesn't HTML escape its param" do
        erector { element! "foo", plain }.should == "<foo>#{plain}</foo>"
      end
    end
  end

  describe "#javascript" do
    context "when receiving a block" do
      it "renders the content inside of script text/javascript tags" do
        expected = <<-EXPECTED
          <script type="text/javascript">
          // <![CDATA[
          if (x < y && x > z) alert("don't stop");
          // ]]>
          </script>
        EXPECTED
        expected.gsub!(/^          /, '')
        erector do
          javascript do
            rawtext 'if (x < y && x > z) alert("don\'t stop");'
          end
        end.should == expected
      end
    end

    it "renders the raw content inside script tags when given text" do
      expected = <<-EXPECTED
        <script type="text/javascript">
        // <![CDATA[
        alert("&<>'hello");
        // ]]>
        </script>
      EXPECTED
      expected.gsub!(/^        /, '')
      erector do
        javascript('alert("&<>\'hello");')
      end.should == expected
    end

    context "when receiving a params hash" do
      it "renders a source file" do
        html = erector do
          javascript(:src => "/my/js/file.js")
        end
        doc = Nokogiri::HTML(html)
        doc.at("script")[:src].should == "/my/js/file.js"
      end
    end

    context "when receiving text and a params hash" do
      it "renders a source file" do
        html = erector do
          javascript('alert("&<>\'hello");', :src => "/my/js/file.js")
        end
        doc = Nokogiri::HTML(html)
        script_tag = doc.at('script')
        script_tag[:src].should == "/my/js/file.js"
        script_tag.inner_html.should include('alert("&<>\'hello");')
      end
    end

    context "with too many arguments" do
      it "raises ArgumentError" do
        proc do
          erector do
            javascript 'foobar', {}, 'fourth'
          end
        end.should raise_error(ArgumentError)
      end
    end
  end

  describe "#close_tag" do
    it "works when it's all alone, even though it messes with the indent level" do
      erector { close_tag :foo }.should == "</foo>"
      erector { close_tag :foo; close_tag :bar }.should == "</foo></bar>"
    end
  end

  describe "exception handling" do
    class RenderWithReturn < Erector::Widget
      def content
        h2 do
          return "returned_value"
          text "don't get here"
        end
      end
    end

    it "closes tags when a block returns" do
      RenderWithReturn.new.to_html.should == "<h2></h2>"
    end

    it "closes tags when a block throws and the exception is caught" do
      erector do
        begin
          div do
            raise "no way"
            text "not reached"
          end
        rescue
        end
      end.should == "<div></div>"
    end

    it "closes tags when throwing block versus text exception" do
      erector do
        begin
          span "a value" do
            text "a block"
          end
        rescue ArgumentError => e
          e.to_s.should include(
            "You can't pass both a block and a value")
        end
      end.should == "<span></span>"
    end
  end

end
