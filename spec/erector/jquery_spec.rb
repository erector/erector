require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::JQuery do
  include Erector::Mixin

  describe "#jquery" do
    def expected(event, *args)

      "<script #{'id="foo" ' if args.include? :id}type=\"text/javascript\">\n" +
              "// <![CDATA[\n\n" +
              "jQuery(document).#{event}(function($){\n" +
              "alert('hello');\n});\n// ]]>\n</script>\n"
    end

    it "outputs a 'jquery ready' script block by default" do
      erector { jquery "alert('hello');" }.should == expected("ready")
    end

    it "outputs attributes" do
      erector { jquery "alert('hello');", :id => 'foo' }.should == expected("ready", :id)
    end

    it "outputs a 'jquery ready' script block when passed a symbol for the first arg" do
      erector { jquery :ready, "alert('hello');" }.should == expected("ready")
    end

    it "outputs a 'jquery load' script block" do
      erector { jquery :load, "alert('hello');" }.should == expected("load")
    end

    it "combines event, text, and attributes" do
      erector { jquery :load, "alert('hello');", :id => "foo" }.should == expected("load", :id)
    end
  end
end
