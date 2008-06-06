require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

module WidgetSpec
  describe Erector::Widget do
    describe ".all_tags" do
      it "returns set of full and empty tags" do
        Erector::Widget.all_tags.class.should == Array
        Erector::Widget.all_tags.should == Erector::Widget.full_tags + Erector::Widget.empty_tags
      end
    end

    describe "#to_s" do
      class << self
        define_method("invokes #render and returns the string representation of the rendered widget") do
          it "invokes #render and returns the string representation of the rendered widget" do
            widget = Erector::Widget.new do
              div "Hello"
            end
            mock.proxy(widget).render
            widget.to_s.should == "<div>Hello</div>"
          end
        end
      end

      context "when passed no arguments" do
        send "invokes #render and returns the string representation of the rendered widget"
      end

      context "when passed an argument that is #render" do
        send "invokes #render and returns the string representation of the rendered widget"
      end

      context "when passed an argument that is not #render" do
        attr_reader :widget
        before do
          @widget = Erector::Widget.new
          def widget.alternate_render
            div "Hello from Alternate Render"
          end
          mock.proxy(widget).alternate_render
        end

        it "invokes the passed in method name and returns the string representation of the rendered widget" do
          widget.to_s(:alternate_render).should == "<div>Hello from Alternate Render</div>"
        end

        it "does not invoke #render" do
          dont_allow(widget).render
          widget.to_s(:alternate_render)
        end
      end
    end

    describe "#instruct" do
      it "when passed no arguments; returns an XML declaration with version 1 and utf-8" do
        html = Erector::Widget.new do
          instruct
          # version must precede encoding, per XML 1.0 4th edition (section 2.8)
        end.to_s.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      end
    end

    describe "#widget" do
      context "when nested" do
        it "renders the tag around the rest of the block" do
          parent_widget = Class.new(Erector::Widget) do
            def render
              div :id => "parent_widget" do
                super
              end
            end
          end
          child_widget = Class.new(Erector::Widget) do
            def render
              div :id => "child_widget" do
                super
              end
            end
          end

          widget = Class.new(Erector::Widget) do
            def render
              widget(parent_widget) do
                widget(child_widget) do
                  super
                end
              end
            end
          end

          widget.new(nil, :parent_widget => parent_widget, :child_widget => child_widget) do
            div :id => "widget"
          end.to_s.should == '<div id="parent_widget"><div id="child_widget"><div id="widget"></div></div></div>'
        end
      end
    end

    describe "#element" do
      context "when receiving one argument" do
        it "returns an empty element" do
          Erector::Widget.new do
            element('div')
          end.to_s.should == "<div></div>"
        end
      end

      context "with a attribute hash" do
        it "returns an empty element with the attributes" do
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
      end

      context "with an array of CSS classes" do
        it "returns a tag with the classes separated" do
          Erector::Widget.new do
            element('div', :class => [:foo, :bar])
          end.to_s.should == "<div class=\"foo bar\"></div>";
        end
      end

      context "with an array of CSS classes as strings" do
        it "returns a tag with the classes separated" do
          Erector::Widget.new do
            element('div', :class => ['foo', 'bar'])
          end.to_s.should == "<div class=\"foo bar\"></div>";
        end
      end


      context "with a CSS class which is a string" do
        it "just use that as the attribute value" do
          Erector::Widget.new do
            element('div', :class => "foo bar")
          end.to_s.should == "<div class=\"foo bar\"></div>";
        end
      end

      context "with many attributes" do
        it "alphabetize them" do
            Erector::Widget.new do
              empty_element('foo', :alpha => "", :betty => "5", :aardvark => "tough",
                :carol => "", :demon => "", :erector => "", :pi => "3.14", :omicron => "", :zebra => "", :brain => "")
            end.to_s.should == "<foo aardvark=\"tough\" alpha=\"\" betty=\"5\" brain=\"\" carol=\"\" demon=\"\" " \
               "erector=\"\" omicron=\"\" pi=\"3.14\" zebra=\"\" />";
          end
      end

      context "with inner tags" do
        it "returns nested tags" do
          widget = Erector::Widget.new do
            element 'div' do
              element 'div'
            end
          end
          widget.to_s.should == '<div><div></div></div>'
        end
      end

      context "with text" do
        it "returns element with inner text" do
          Erector::Widget.new do
            element 'div', 'test text'
          end.to_s.should == "<div>test text</div>"
        end
      end

      context "with object other than hash" do
        it "returns element with inner text == object.to_s" do
          object = ['a', 'b']
          Erector::Widget.new do
            element 'div', object
          end.to_s.should == "<div>#{object.to_s}</div>"
        end
      end

      context "with parameters and block" do
        it "returns element with inner html and attributes" do
          Erector::Widget.new do
            element 'div', 'class' => "foobar" do
              element 'span', 'style' => 'display: none;'
            end
          end.to_s.should == '<div class="foobar"><span style="display: none;"></span></div>'
        end
      end

      context "with content and parameters" do
        it "returns element with content as inner html and attributes" do
          Erector::Widget.new do
            element 'div', 'test text', :style => "display: none;"
          end.to_s.should == '<div style="display: none;">test text</div>'
        end
      end

      context "with more than three arguments" do
        it "raises ArgumentError" do
          proc do
            Erector::Widget.new do
              element 'div', 'foobar', {}, 'fourth'
            end.to_s
          end.should raise_error(ArgumentError)
        end
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

      describe "quoting" do
        context "when outputting text" do
          it "quotes it" do
            Erector::Widget.new do
              element 'div', 'test &<>text'
            end.to_s.should == "<div>test &amp;&lt;&gt;text</div>"
          end
        end

        context "when outputting text via text" do
          it "quotes it" do
            Erector::Widget.new do
              element 'div' do
                text "test &<>text"
              end
            end.to_s.should == "<div>test &amp;&lt;&gt;text</div>"
          end
        end

        context "when outputting attribute value" do
          it "quotes it" do
            Erector::Widget.new do
              element 'a', :href => "foo.cgi?a&b"
            end.to_s.should == "<a href=\"foo.cgi?a&amp;b\"></a>"
          end
        end

        context "with raw text" do
          it "does not quote it" do
            Erector::Widget.new do
              element 'div' do
                text raw("<b>bold</b>")
              end
            end.to_s.should == "<div><b>bold</b></div>"
          end
        end

        context "with raw text and no block" do
          it "does not quote it" do
            Erector::Widget.new do
              element 'div', raw("<b>bold</b>")
            end.to_s.should == "<div><b>bold</b></div>"
          end
        end

        context "with raw attribute" do
          it "does not quote it" do
            Erector::Widget.new do
              element 'a', :href => raw("foo?x=&nbsp;")
            end.to_s.should == "<a href=\"foo?x=&nbsp;\"></a>"
          end
        end

        context "with quote in attribute" do
          it "quotes it" do
            Erector::Widget.new do
              element 'a', :onload => "alert(\"foo\")"
            end.to_s.should == "<a onload=\"alert(&quot;foo&quot;)\"></a>"
          end
        end
      end

      context "with a non-string, non-raw" do
        it "calls to_s and quotes" do
          Erector::Widget.new do
            element 'a' do
              text [7, "foo&bar"]
            end
          end.to_s.should == "<a>7foo&amp;bar</a>"
        end
      end
    end

    describe "#empty_element" do
      context "when receiving attributes" do
        it "renders an empty element with the attributes" do
          Erector::Widget.new do
            empty_element 'input', :name => 'foo[bar]'
          end.to_s.should == '<input name="foo[bar]" />'
        end
      end

      context "when not receiving attributes" do
        it "renders an empty element without attributes" do
          Erector::Widget.new do
            empty_element 'br'
          end.to_s.should == '<br />'
        end
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
      context "when receiving a block" do
        it "renders the content inside of script text/javascript tags" do
          expected = <<-EXPECTED
            <script type="text/javascript">
            // <![CDATA[
            if (x < y && x > z) alert("don't stop");
            // ]]>
            </script>
          EXPECTED
          expected.gsub!(/^            /, '')
          Erector::Widget.new do
            javascript do
              rawtext 'if (x < y && x > z) alert("don\'t stop");'
            end
          end.to_s.should == expected
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
        expected.gsub!(/^          /, '')
        Erector::Widget.new do
          javascript('alert("&<>\'hello");')
        end.to_s.should == expected
      end

      context "when receiving a params hash" do
        it "renders a source file" do
          html = Erector::Widget.new do
            javascript(:src => "/my/js/file.js")
          end.to_s
          doc = Hpricot(html)
          doc.at('/')[:src].should == "/my/js/file.js"
        end
      end

      context "when receiving text and a params hash" do
        it "renders a source file" do
          html = Erector::Widget.new do
            javascript('alert("&<>\'hello");', :src => "/my/js/file.js")
          end.to_s
          doc = Hpricot(html)
          script_tag = doc.at('script')
          script_tag[:src].should == "/my/js/file.js"
          script_tag.inner_html.should include('alert("&<>\'hello");')
        end
      end

      context "with too many arguments" do
        it "raises ArgumentError" do
          proc do
            Erector::Widget.new do
              javascript 'foobar', {}, 'fourth'
            end.to_s
          end.should raise_error(ArgumentError)
        end
      end
    end

    describe "#css" do
      it "makes a link when passed a string" do
        Erector::Widget.new do
          css "erector.css"
        end.to_s.should == "<link href=\"erector.css\" rel=\"stylesheet\" type=\"text/css\" />"
      end
    end

    describe "#url" do
      it "renders an anchor tag with the same href and text" do
        Erector::Widget.new do
          url "http://example.com"
        end.to_s.should == "<a href=\"http://example.com\">http://example.com</a>"
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

    describe 'nested' do
      it "can insert another widget without raw" do
        inner = Erector::Widget.new do
          p "foo"
        end

        outer = Erector::Widget.new do
          div inner
        end.to_s.should == '<div><p>foo</p></div>'
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

    describe '#render_to' do
      class A < Erector::Widget
        def render
          p "A"
        end
      end

      it "renders to a doc" do
        class B < Erector::Widget
          def render
            text "B"
            A.new.render_to(@doc)
            text "B"
          end
        end
        b = B.new
        b.to_s.should == "B<p>A</p>B"
        b.doc.size.should == 10  # B, <p>, A, </p>, B
      end

      it "renders to a widget's doc" do
        class B < Erector::Widget
          def render
            text "B"
            A.new.render_to(self)
            text "B"
          end
        end
        b = B.new
        b.to_s.should == "B<p>A</p>B"
        b.doc.size.should == 10  # B, <p>, A, </p>, B
      end

      it "passing a widget to text method renders it" do
        Erector::Widget.new() do
          text "B"
          text A.new()
          text "B"
        end.to_s.should == "B<p>A</p>B"
      end

    end
  end
end

