require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module WidgetSpec
  describe Erector::Widget do
    describe ".all_tags" do
      it "returns set of full and empty tags" do
        Erector::Widget.all_tags.class.should == Array
        Erector::Widget.all_tags.should == Erector::Widget.full_tags + Erector::Widget.empty_tags
      end
    end

    describe "#instruct!" do
      it "when passed no arguments; returns an instruct element with version 1 and utf-8" do
        html = Erector::Widget.new do
          instruct!
          # version must precede encoding, per XML 1.0 4th edition (section 2.8)
        end.to_s.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      end
    end

    describe "#element" do
      it "when receiving one argument; returns an empty element" do
        Erector::Widget.new do
          element('div')
        end.to_s.should == "<div></div>"
      end

      it "with a attribute hash; returns an empty element with the attributes" do
        html = Erector::Widget.new do
          element(
            'div',
              :class => "foo bar",
              :style => "display: none; color: white; float: left;",
              :nil_attribute => nil
          )
        end.to_s
        doc = Hpricot(html)
        div = doc.at('div')
        div[:class].should == "foo bar"
        div[:style].should == "display: none; color: white; float: left;"
        div[:nil_attribute].should be_nil
      end

      it "with an array of CSS classes, returns a tag with the classes separated" do
        Erector::Widget.new do
          element('div', :class => [:foo, :bar])
        end.to_s.should == "<div class=\"foo bar\"></div>";
      end

      it "with an array of CSS classes as strings, returns a tag with the classes separated" do
        Erector::Widget.new do
          element('div', :class => ['foo', 'bar'])
        end.to_s.should == "<div class=\"foo bar\"></div>";
      end

      it "with a CSS class which is a string, just use that as the attribute value" do
        Erector::Widget.new do
          element('div', :class => "foo bar")
        end.to_s.should == "<div class=\"foo bar\"></div>";
      end

      it "with many attributes, alphabetize them" do
        Erector::Widget.new do
          empty_element('foo', :alpha => "", :betty => "5", :aardvark => "tough",
            :carol => "", :demon => "", :erector => "", :pi => "3.14", :omicron => "", :zebra => "", :brain => "")
        end.to_s.should == "<foo aardvark=\"tough\" alpha=\"\" betty=\"5\" brain=\"\" carol=\"\" demon=\"\" " \
           "erector=\"\" omicron=\"\" pi=\"3.14\" zebra=\"\" />";
      end

      it "with inner tags; returns nested tags" do
        widget = Erector::Widget.new do
          element 'div' do
            element 'div'
          end
        end
        widget.to_s.should == '<div><div></div></div>'
      end

      it "with text; returns element with inner text" do
        Erector::Widget.new do
          element 'div', 'test text'
        end.to_s.should == "<div>test text</div>"
      end

      it "with object other than hash; returns element with inner text == object.to_s" do
        object = ['a', 'b']
        Erector::Widget.new do
          element 'div', object
        end.to_s.should == "<div>#{object.to_s}</div>"
      end

      it "with parameters and block; returns element with inner html and attributes" do
        Erector::Widget.new do
          element 'div', 'class' => "foobar" do
            element 'span', 'style' => 'display: none;'
          end
        end.to_s.should == '<div class="foobar"><span style="display: none;"></span></div>'
      end

      it "with content and parameters; returns element with content as inner html and attributes" do
        Erector::Widget.new do
          element 'div', 'test text', :style => "display: none;"
        end.to_s.should == '<div style="display: none;">test text</div>'
      end

      it "with more than three arguments; raises ArgumentError" do
        proc do
          Erector::Widget.new do
            element 'div', 'foobar', {}, 'fourth'
          end.to_s
        end.should raise_error(ArgumentError)
      end

      it "renders the proper full tags" do
        Erector::Widget.full_tags.each do |tag_name|
          expected = "<#{tag_name}></#{tag_name}>"
          actual = Erector::Widget.new do
            send(tag_name)
          end.to_s
          begin
            actual.should == expected
          rescue Spec::Expectations::ExpectationNotMetError => e
            puts "Expected #{tag_name} to be a full element. Expected #{expected}, got #{actual}"
            raise e
          end
        end
      end

      it "when outputting text; quotes it" do
        Erector::Widget.new do
          element 'div', 'test &<>text'
        end.to_s.should == "<div>test &amp;&lt;&gt;text</div>"
      end

      it "when outputting text via text; quotes it" do
        Erector::Widget.new do
          element 'div' do
            text "test &<>text"
          end
        end.to_s.should == "<div>test &amp;&lt;&gt;text</div>"
      end

      it "when outputting attribute value; quotes it" do
        Erector::Widget.new do
          element 'a', :href => "foo.cgi?a&b"
        end.to_s.should == "<a href=\"foo.cgi?a&amp;b\"></a>"
      end

      it "with raw text, does not quote it" do
        Erector::Widget.new do
          element 'div' do
            text raw("<b>bold</b>")
          end
        end.to_s.should == "<div><b>bold</b></div>"
      end

      it "with raw text and no block, does not quote it" do
        Erector::Widget.new do
          element 'div', raw("<b>bold</b>")
        end.to_s.should == "<div><b>bold</b></div>"
      end

      it "with raw attribute, does not quote it" do
        Erector::Widget.new do
          element 'a', :href => raw("foo?x=&nbsp;")
        end.to_s.should == "<a href=\"foo?x=&nbsp;\"></a>"
      end

      it "with quote in attribute, quotes it" do
        Erector::Widget.new do
          element 'a', :onload => "alert(\"foo\")"
        end.to_s.should == "<a onload=\"alert(&quot;foo&quot;)\"></a>"
      end

      it "with a non-string, non-raw, calls to_s and quotes" do
        Erector::Widget.new do
          element 'a' do
            text [7, "foo&bar"]
          end
        end.to_s.should == "<a>7foo&amp;bar</a>"
      end

    end

    describe "#empty_element" do
      it "when receiving attributes, renders an empty element with the attributes" do
        Erector::Widget.new do
          empty_element 'input', :name => 'foo[bar]'
        end.to_s.should == '<input name="foo[bar]" />'
      end

      it "when not receiving attributes, renders an empty element without attributes" do
        Erector::Widget.new do
          empty_element 'br'
        end.to_s.should == '<br />'
      end

      it "renders the proper empty-element tags" do
        ['area', 'base', 'br', 'hr', 'img', 'input', 'link', 'meta'].each do |tag_name|
          expected = "<#{tag_name} />"
          actual = Erector::Widget.new do
            send(tag_name)
          end.to_s
          begin
            actual.should == expected
          rescue Spec::Expectations::ExpectationNotMetError => e
            puts "Expected #{tag_name} to be an empty-element tag. Expected #{expected}, got #{actual}"
            raise e
          end
        end
      end
    end

    describe "nbsp" do
      it "turns consecutive spaces into consecutive non-breaking spaces" do
        Erector::Widget.new do
          text nbsp("a  b")
        end.to_s.should == "a&#160;&#160;b"
      end

      it "works in text context" do
        Erector::Widget.new do
          element 'a' do
            text nbsp("&<> foo")
          end
        end.to_s.should == "<a>&amp;&lt;&gt;&#160;foo</a>"
      end

      it "works in attribute value context" do
        Erector::Widget.new do
          element 'a', :href => nbsp("&<> foo")
        end.to_s.should == "<a href=\"&amp;&lt;&gt;&#160;foo\"></a>"
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

    describe "#javascript" do
      it "when receiving a block; renders the content inside of script text/javascript tags" do
        Erector::Widget.new do
          javascript do
            rawtext 'if (x < y && x > z) alert("don\'t stop");'
          end
        end.to_s.should == <<EXPECTED
<script type="text/javascript">
// <![CDATA[
if (x < y && x > z) alert("don't stop");
// ]]>
</script>
EXPECTED
      end

      it "when receiving a params hash; renders a source file" do
        html = Erector::Widget.new do
          javascript(:src => "/my/js/file.js")
        end.to_s
        doc = Hpricot(html)
        doc.at('/')[:src].should == "/my/js/file.js"
      end

      it "when receiving text and a params hash; renders a source file" do
        html = Erector::Widget.new do
          javascript('alert("&<>\'hello");', :src => "/my/js/file.js")
        end.to_s
        doc = Hpricot(html)
        script_tag = doc.at('script')
        script_tag[:src].should == "/my/js/file.js"
        script_tag.inner_html.should include('alert("&<>\'hello");')
      end

      it "with too many arguments; raises ArgumentError" do
        proc do
          Erector::Widget.new do
            javascript 'foobar', {}, 'fourth'
          end.to_s
        end.should raise_error(ArgumentError)
      end

      it "script method doesn't do any magic" do
        Erector::Widget.new do
          script(:type => "text/javascript") do
            rawtext "if (x < y || x > z) onEnterGetTo('/search?a=b&c=d')"
          end
        end.to_s.should == "<script type=\"text/javascript\">if (x < y || x > z) onEnterGetTo('/search?a=b&c=d')</script>"
      end

    end

    describe '#capture' do
      it "should return content rather than write it to the buffer" do
        widget = Erector::Widget.new do
          captured = capture do
            p 'Captured Content'
          end
          div do
            text captured
          end
        end
        widget.to_s.should == '<div><p>Captured Content</p></div>'
      end

      it "works with nested captures" do
        widget = Erector::Widget.new do
          captured = capture do
            captured = capture do
              p 'Nested Capture'
            end
            p 'Captured Content'
            text captured
          end
          div do
            text captured
          end
        end
        widget.to_s.should == '<div><p>Captured Content</p><p>Nested Capture</p></div>'
      end
    end

    describe '#widget' do
      before do
        class Parent < Erector::Widget
          def render
            text 1
            widget Child do
              text 2
              third
            end
          end

          def third
            text 3
          end
        end

        class Child < Erector::Widget
          def render
            super
          end
        end
      end

      it "renders nested widgets in the correct order" do
        Parent.new.to_s.should == '123'
      end
    end
  end
end
