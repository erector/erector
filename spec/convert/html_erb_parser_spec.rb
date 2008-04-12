dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

# require 'test/unit'
require 'rubygems'
require 'treetop'
require "erector/erected"  # pull this out so we don't recreate the grammar every time

module ParserTestHelper
  def assert_evals_to_self(input)
    assert_evals_to(input, input)
  end

  def parse(input)
    result = @parser.parse(input).set_indent(0)
    unless result
      puts @parser.terminal_failures.join("\n")
    end
    result.should_not be_nil
    result
  end
end

describe HtmlErbParser do
  include ParserTestHelper
  
  before :each do
    @parser = HtmlErbParser.new
  end
  
  it "converts text" do
    parse("hello").convert.should == "text 'hello'\n"
    parse("hello maude!").convert.should == "text 'hello maude!'\n"
    parse(" hello ").convert.should == "text 'hello'\n"
  end

  it "converts self-closing tags" do
    parse("<br/>").convert.should == "br\n"
    parse("<br />").convert.should == "br\n"
  end

  it "converts open tag" do
    parse("<div>").convert.should == "div do\n"
    parse("<h1>").convert.should == "h1 do\n"
  end

  it "converts close tag" do
    parse("</div>").convert.should == "end\n"
    parse("</h1>").convert.should == "end\n"
  end

  it "converts two nested divs" do
    parse("<div><div></div></div>").convert.should ==
      "div do\n" +
      "  div do\n" +
      "  end\n" +
      "end\n"
  end

  it "converts two nested divs with whitespace" do
    parse("<div> <div> </div> </div>").convert.should ==
      "div do\n" +
      "  div do\n" +
      "  end\n" +
      "end\n"
  end

  it "converts no open, text, and no close tag" do
    parse("hello</div>").convert.should == "text 'hello'\nend\n"
  end

  it "converts open, text, and no close tag" do
    parse("<div>hello").convert.should == "div do\n  text 'hello'\n"
  end

  it "converts open, text, close" do
    parse("<div>hello</div>").convert.should == "div do\n  text 'hello'\nend\n"
  end

  it "converts a scriptlet" do
    parse("<% foo %>").convert.should == "foo\n"
  end

  it "converts open, text, scriptlet, text, close" do
    parse("<div>hello <% 5.times do %> very <% end %> much</div>").convert.should ==
      "div do\n" +
      "  text 'hello'\n" +
      "  5.times do\n" +
      "    text 'very'\n" +
      "  end\n" +
      "  text 'much'\n" +
      "end\n"
  end

  it "converts open, scriptlet, text, close" do
    parse("<div><% 5.times do %> very <% end %> much</div>").convert.should ==
      "div do\n" +
      "  5.times do\n" +
      "    text 'very'\n" +
      "  end\n" +
      "  text 'much'\n" +
      "end\n"
  end

  it "converts open, text, scriptlet, close" do
    parse("<div>hello <% 5.times do %> very <% end %></div>").convert.should ==
      "div do\n" +
      "  text 'hello'\n" +
      "  5.times do\n" +
      "    text 'very'\n" +
      "  end\n" +
      "end\n"
  end

  it "converts printlets into rawtext statements" do
    parse("<%= 1+1 %>").convert.should == "rawtext 1+1\n"
    parse("<%= link_to \"mom\" %>").convert.should == "rawtext link_to \"mom\"\n"
  end

  it "converts h-printlets into text statements" do
    parse("<%=h foo %>").convert.should == "text foo\n"
    parse("<%= h \"mom\" %>").convert.should == "text \"mom\"\n"
  end

  it "understand percents inside scriptlets" do
    pending do
      parse("<% x = 10 % 5 %>").convert.should == "x = 10 % 5"
    end
  end

  it "indents" do
    i = Erector::Indenting.new(nil, nil)
    i.line("foo").should ==     "foo\n"
    i.line_in("bar").should ==  "bar\n"
    i.line_in("baz").should ==  "  baz\n"
    i.line("baf").should ==     "    baf\n"
    i.line_out("end").should == "  end\n"
    i.line_out("end").should == "end\n"
  end

  it "indents extra when told to" do
    parse("<div>hello</div>").set_indent(2).convert.should ==
      "    div do\n" +
      "      text 'hello'\n" +
      "    end\n"
  end

  it "indents scriptlets ending with do and end" do
    parse("<% form_for :foo do |x,y| %><% 5.times do %>hello<% end %><% end %>bye").convert.should ==
      "form_for :foo do |x,y|\n" +
      "  5.times do\n" +
      "    text 'hello'\n" +
      "  end\n" +
      "end\n" +
      "text 'bye'\n"
  end

  it "converts HTML attributes"

  ## More functional-type specs below here

  it "ignores spaces, tabs and newlines" do
    parse("  <div>\t\n" + "\thello !" + "\n\t</div>").convert.should ==
      "div do\n" +
      "  text 'hello !'\n" +
      "end\n"
  end

  it "parses some scaffolding" do
    parse("""<p>
  <b>Name:</b>
  <%=h @foo.name %>
</p>""").convert.should ==
      "p do\n" +
      "  b do\n" +
      "    text 'Name:'\n" +
      "  end\n" +
      "  text @foo.name\n" +
      "end\n"
  end

  it "parses edit.erb.html" do
    parse("""<h1>Editing foo</h1>

<%= error_messages_for :foo %>

<% form_for(@foo) do |f| %>
  <p>
    <b>Name</b><br />
    <%= f.text_field :name %>
  </p>

  <p>
    <b>Age</b><br />
    <%= f.text_field :age %>
  </p>

  <p>
    <%= f.submit \"Update\" %>
  </p>
<% end %>

<%= link_to 'Show', @foo %> |
<%= link_to 'Back', foos_path %>
""")
  end

  it "parses show.html.erb" do
    parse("""<p>
  <b>Name:</b>
  <%=h @foo.name %>
</p>

<p>
  <b>Age:</b>
  <%=h @foo.age %>
</p>


<%= link_to 'Edit', edit_foo_path(@foo) %> |
<%= link_to 'Back', foos_path %>
""")
  end

end
