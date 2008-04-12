dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

# require 'test/unit'
require 'rubygems'
require 'treetop'
Treetop.load "#{dir}/../../lib/erector/html_erb"

module ParserTestHelper
  def assert_evals_to_self(input)
    assert_evals_to(input, input)
  end

  def parse(input)
    result = @parser.parse(input)
    unless result
      puts @parser.terminal_failures.join("\n")
    end
    result.should_not be_nil
    result
  end
end


describe "parser" do
  include ParserTestHelper
  
  before :each do
    @parser = HtmlErbParser.new
  end
  
  it "parses text" do
    parse("hello").convert.should == "text 'hello'\n"
    parse("hello maude!").convert.should == "text 'hello maude!'\n"
    parse(" hello ").convert.should == "text 'hello'\n"
  end

  it "parses self-closing tags" do
    parse("<br/>").convert.should == "br\n"
    parse("<br />").convert.should == "br\n"
  end

  it "parses open tag" do
    parse("<div>").convert.should == "div do\n"
  end

  it "parses close tag" do
    parse("</div>").convert.should == "end\n"
  end

  it "parses two nested divs" do
    parse("<div><div></div></div>").convert.should ==
      "div do\n" +
        "div do\n" +
        "end\n" +
      "end\n"

  end

  it "parses two nested divs with whitespace" do
    parse("<div> <div> </div> </div>").convert.should ==
      "div do\n" +
        "div do\n" +
        "end\n" +
      "end\n"
  end

  it "parses no open, text, and no close tag" do
    parse("hello</div>").convert.should == "text 'hello'\nend\n"
  end

  it "parses open, text, and no close tag" do
    parse("<div>hello").convert.should == "div do\ntext 'hello'\n"
  end

  it "parses open, text, close" do
    parse("<div>hello</div>").convert.should == "div do\ntext 'hello'\nend\n"
  end

  it "parses a scriptlet" do
    parse("<% foo %>").convert.should == "foo\n"
  end

  it "parses open, text, scriptlet, text, close" do
    parse("<div>hello <% 5.times do %> very <% end %> much</div>").convert.should ==
      "div do\n" +
        "text 'hello'\n" +
        "5.times do\n" +
          "text 'very'\n" +
        "end\n" +
        "text 'much'\n" +
      "end\n"
  end

  it "parses open, scriptlet, text, close" do
    parse("<div><% 5.times do %> very <% end %> much</div>").convert.should ==
      "div do\n" +
        "5.times do\n" +
          "text 'very'\n" +
        "end\n" +
        "text 'much'\n" +
      "end\n"
  end

  it "parses open, text, scriptlet, close" do
    parse("<div>hello <% 5.times do %> very <% end %></div>").convert.should ==
      "div do\n" +
        "text 'hello'\n" +
        "5.times do\n" +
          "text 'very'\n" +
        "end\n" +
      "end\n"
  end

  it "parses printlets" do
    parse("<%= 1+1 %>").convert.should == "text 1+1\n"
    parse("<%= link_to \"mom\" %>").convert.should == "text link_to \"mom\"\n"
  end

end
