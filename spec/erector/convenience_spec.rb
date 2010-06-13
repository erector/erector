require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::Convenience do
  include Erector::Mixin

  describe "#to_pretty" do
    it "calls to_s with :prettyprint => true"
    it "passes extra attributes through to to_s"
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

    it "passes extra attributes through to to_s"
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

    it "passes extra attributes through"
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
      widget.to_s.should == "<div id=\"#{widget.dom_id}\"></div>"
    end
  end
end
