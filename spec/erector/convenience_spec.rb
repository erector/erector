require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::Convenience do
  include Erector::Mixin

  describe "#to_pretty" do
    it "calls to_html with :prettyprint => true" do
      widget = Erector.inline do
        div "foo"
      end
      mock(widget).to_html({:prettyprint => true})
      widget.to_pretty
    end

    it "passes extra options through to to_html" do
      pending "RR problem with Ruby 1.9" if RUBY_VERSION >= "1.9.0"
      widget = Erector.inline do
        div "foo"
      end
      mock(widget).to_html({:prettyprint => true, :extra => "yay"})
      widget.to_pretty(:extra => "yay")
    end
  end

  describe "#to_s" do
    it "returns html" do
      capturing_stderr do
        Erector.inline do
          div "foo"
        end.to_s.should == "<div>foo</div>"
      end
    end
  end

  describe "#to_html" do
    it "returns html" do
      Erector.inline do
        div "foo"
      end.to_html.should == "<div>foo</div>"
    end
  end

  describe "#to_text" do
    it "strips tags" do
      Erector.inline do
        div "foo"
      end.to_text.should == "foo"
    end

    it "unescapes named entities" do
      s = "my \"dog\" has fleas & <ticks>"
      Erector.inline do
        text s
      end.to_text.should == s
    end

    it "ignores >s inside attribute strings" do
      Erector.inline do
        a "foo", :href => "http://example.com/x>y"
      end.to_text.should == "foo"
    end

    def with_prettyprint_default(value = true)
      old_default = Erector::Widget.new.prettyprint_default
      begin
        Erector::Widget.prettyprint_default = value
        yield
      ensure
        Erector::Widget.prettyprint_default = old_default
      end
    end

    it "doesn't inherit unwanted pretty-printed whitespace (i.e. it turns off prettyprinting)" do
      with_prettyprint_default(true) do
        Erector.inline do
          div { div { div "foo" } }
        end.to_text.should == "foo"
      end
    end

    it "passes extra attributes through to to_s" do
      class Funny < Erector::Widget
        def content
          div "foo"
        end

        def funny
          div "haha"
        end
      end
      Funny.new.to_text(:content_method_name => :funny).should == "haha"
    end

    it "doesn't turn a p into a newline if it's at the beginning of the string" do
      Erector.inline do
        p "hi"
      end.to_text.should == "hi\n"
    end

    it "puts a blank line (two newlines) after a /p tag" do
      Erector.inline do
        p "first paragraph"
        p "second paragraph"
      end.to_text.should == "first paragraph\n\nsecond paragraph\n"
    end

    it "separates p tags with attributes" do
      Erector.inline do
        p "first paragraph", :class => "first"
        p "second paragraph", :class => "second"
      end.to_text.should == "first paragraph\n\nsecond paragraph\n"
    end

    it "puts a newline after a br tag" do
      Erector.inline do
        text "first line"
        br
        text "second line"
      end.to_text.should == "first line\nsecond line"
    end

    it "formats a UL (unordered list) using asterisks for bullets" do
      Erector.inline do
        ul do
          li "vanilla"
          li "chocolate"
          li "strawberry"
        end
      end.to_text.should == "\n* vanilla\n* chocolate\n* strawberry\n"
    end

    # it's too hard to keep track of numbers with a regexp munger, so just use asterisks for bullets
    # todo: integrate text output into core rendering code
    it "formats an OL (ordered list)" do
      Erector.inline do
        ol do
          li "vanilla"
          li "chocolate"
          li "strawberry"
        end
      end.to_text.should == "\n* vanilla\n* chocolate\n* strawberry\n"
    end
  end

  describe "#join" do
    it "empty array means nothing to join" do
      erector do
        join [], Erector::Widget.new { text "x" }
      end.should == ""
    end

    it "larger example with two tabs" do
      erector do
        tab1 =
                Erector.inline do
                  a "Upload document", :href => "/upload"
                end
        tab2 =
                Erector.inline do
                  a "Logout", :href => "/logout"
                end
        join [tab1, tab2],
             Erector::Widget.new { text nbsp(" |"); text " " }
      end.should ==
              '<a href="/upload">Upload document</a>&#160;| <a href="/logout">Logout</a>'
    end

    it "plain string as join separator means pass it to text" do
      erector do
        join [
                Erector::Widget.new { text "x" },
                Erector::Widget.new { text "y" }
        ], "<>"
      end.should == "x&lt;&gt;y"
    end

    it "plain string as item to join means pass it to text" do
      erector do
        join [
                "<",
                "&"
        ], Erector::Widget.new { text " + " }
      end.should == "&lt; + &amp;"
    end
  end

  describe "#css" do
    it "makes a link when passed a string" do
      erector do
        css "erector.css"
      end.should == "<link href=\"erector.css\" rel=\"stylesheet\" type=\"text/css\" />"
    end

    it "accepts a media attribute" do
      erector do
        css "print.css", :media => "print"
      end.should == "<link href=\"print.css\" media=\"print\" rel=\"stylesheet\" type=\"text/css\" />"
    end

    it "passes extra attributes through" do
      erector { css "foo.css", :title => 'Foo' }.should == "<link href=\"foo.css\" rel=\"stylesheet\" title=\"Foo\" type=\"text/css\" />"
    end
  end

  describe "#url" do
    it "renders an anchor tag with the same href and text" do
      erector do
        url "http://example.com"
      end.should == "<a href=\"http://example.com\">http://example.com</a>"
    end

    it "accepts extra attributes" do
      erector do
        url "http://example.com", :onclick=>"alert('foo')"
      end.should == "<a href=\"http://example.com\" onclick=\"alert('foo')\">http://example.com</a>"
    end

  end

  describe "#dom_id" do
    class DOMIDWidget < Erector::Widget
      def content
        div :id => dom_id
      end
    end

    it "makes a unique id based on the widget's class name and object id" do
      widget = DOMIDWidget.new
      widget.dom_id.should include("#{widget.object_id}")
      widget.dom_id.should include("DOMIDWidget")
    end

    it "can be used as an HTML id" do
      widget = DOMIDWidget.new
      widget.to_html.should == "<div id=\"#{widget.dom_id}\"></div>"
    end

    describe 'for a namespaced widget class' do

      module ::ErectorConvenienceSpec
        class NestedWidget < Erector::Widget
        end
      end

      it 'is colon escaped' do
        g = ErectorConvenienceSpec::NestedWidget.new
        g.dom_id.should_not =~ /:/
      end

      it 'combines all parent namespaces' do
        g = ErectorConvenienceSpec::NestedWidget.new
        g.dom_id.should == "ErectorConvenienceSpec_NestedWidget_#{g.object_id}"
      end

    end

  end
end

