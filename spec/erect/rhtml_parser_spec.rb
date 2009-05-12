require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

require "erector/erect"

module ParserTestHelper
  def assert_evals_to_self(input)
    assert_evals_to(input, input)
  end

  def parse(input)
    result = @parser.parse(input)
    if result
      result.set_indent(0) if result.respond_to? :set_indent
    else
      puts @parser.failure_reason
      puts @parser.terminal_failures.join("\n")
      result.should_not be_nil
    end
    result
  end
end

describe RhtmlParser do
  include ParserTestHelper
  
  before :each do
    @parser = RhtmlParser.new
  end
  
  it "converts text" do
    parse("hello").convert.should == "text 'hello'\n"
    parse("hello maude!").convert.should == "text 'hello maude!'\n"
    parse(" hello ").convert.should == "text 'hello'\n"
  end
  
  it "unescapes HTML entities in text" do
      parse("&lt;").convert.should == "text '<'\n"
      parse("5 &gt; 2").convert.should == "text '5 > 2'\n"
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
  
  it "autocloses an img tag" do
    parse("<img src='foo'>").convert.should == "img :src => 'foo'\n"
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
    parse("<%= link_to \"mom\" %>").convert.should == "rawtext link_to(\"mom\")\n"
  end

  it "converts h-printlets into text statements" do
    parse("<%=h foo %>").convert.should == "text foo\n"
    parse("<%= h \"mom\" %>").convert.should == "text \"mom\"\n"
  end

  it "allows naked percent signs inside scriptlets" do
      parse("<% x = 10 % 5 %>").convert.should == "x = 10 % 5\n"
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

  it "converts HTML attributes" do
    parse("<div id='foo'/>").convert.should == "div :id => 'foo'\n"
    parse("<div id='foo' class='bar'/>").convert.should == "div :id => 'foo', :class => 'bar'\n"
    parse("<div id='foo'>bar</div>").convert.should == "div :id => 'foo' do\n  text 'bar'\nend\n"    
  end
  
  it "escapes single quotes inside attribute values" do
    @parser.root = :attribute
    parse("a=\"don't worry\"").convert.should == ":a => 'don\\'t worry'"
  end

  it "allows newlines where whitespace is allowed" do
    parse("<img src='foo' \nalt='bar' />").convert.should == "img :src => 'foo', :alt => 'bar'\n"
  end
  
  it "treats tab characters the same as spaces" do
    parse("<div \t />").convert.should == "div\n"
  end
  
  it "deals with HTML entities in text" do
    parse("&lt;").convert.should == "text '<'\n"
  end

  it "deals with a naked less-than or greater-than sign inside text" do
    parse("if x > 2 or x< 5 then").convert.should == "text 'if x > 2 or x< 5 then'\n"
  end

  it "wraps printlets in parens if necessary, to avoid warning: parenthesize argument(s) for future version" do
    parse("<%= h \"mom\" %>").convert.should == "text \"mom\"\n"
    parse("<%= h hi \"mom\" %>").convert.should == "text hi(\"mom\")\n"

    parse("<%= \"mom\" %>").convert.should == "rawtext \"mom\"\n"
    parse("<%= \"hi mom\" %>").convert.should == "rawtext \"hi mom\"\n"
    parse("<%= hi \"mom\" %>").convert.should == "rawtext hi(\"mom\")\n"

    parse("<%= link_to blah %>").convert.should == "rawtext link_to(blah)\n"
    parse("<%= link_to blah blah %>").convert.should == "rawtext link_to(blah blah)\n"
    parse("<%= link_to blah(blah) %>").convert.should == "rawtext link_to(blah(blah))\n"

    parse("<%= link_to(blah) %>").convert.should == "rawtext link_to(blah)\n"
  end
  
  it "won't parenthesize expressions" do
    parse("<%= h foo / bar %>").convert.should == "text foo / bar\n"
  end

  it "understands a varname" do
    @parser.root = :varname
    parse("head").text_value.should == "head"
  end
  
  it "converts yield printlet into a use of @content_for_layout, commented for your edification" do
    parse("<%= yield  %>").convert.should == "rawtext @content_for_layout # Note: you must define @content_for_layout elsewhere\n"
    parse("<%=  yield :head   %>").convert.should == "rawtext @content_for_head # Note: you must define @content_for_head elsewhere\n"
    parse("<%= \"yield\" %>").convert.should == "rawtext \"yield\"\n"
    parse("<%= \"the yield is good\" %>").convert.should == "rawtext \"the yield is good\"\n"
  end
  
  it "parses quoted strings" do
    @parser.root = :quoted
    parse("'foo'").value.should == "foo"
    parse("\"foo\"").value.should == "foo"
  end

  it "converts attributes in isolation" do
    @parser.root = :attribute
    parse("a='foo'").convert.should == ":a => 'foo'"
    parse("a=\"foo\"").convert.should == ":a => 'foo'"
  end
  
  it "parses a set of attributes" do
    @parser.root = :attributes
    parse("a='foo' b='bar'").convert.should == " :a => 'foo', :b => 'bar'"
  end
  
  it "works with namespaced attributes" do
    @parser.root = :attribute
    parse('xml:lang="en"').convert.should == "'xml:lang' => 'en'"
  end
  
  it "deals with HTML entities in attribute values" do
    @parser.root = :attribute
    parse("foo='b<r'").convert.should == ":foo => 'b<r'"
    parse("foo='b&lt;r'").convert.should == ":foo => 'b<r'"
  end

  it "converts DOCTYPEs" do
    html = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
           "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
    parse(html).convert.should == "rawtext '#{html}'\n"
  end
  
  ["<!--[if IE]>", "<![endif]-->", "<![if !IE]>", "<![endif]>", "<!--[if IE 5.5000]>", "<!--[if IE 6]>"].each do |html|
    it "converts IE directive '#{html}'" do
      parse(html).convert.should == "rawtext '#{html}'\n"
    end
  end

  ## More functional-type specs below here

  it "ignores spaces, tabs and newlines" do
    parse("  <div>\t\n" + "\thello !" + "\n\t</div>").convert.should ==
      "div do\n" +
      "  text 'hello !'\n" +
      "end\n"
  end

  it "parses some scaffolding" do
    parse("<p>
  <b>Name:</b>
  <%=h @foo.name %>
</p>").convert.should ==
      "p do\n" +
      "  b do\n" +
      "    text 'Name:'\n" +
      "  end\n" +
      "  text @foo.name\n" +
      "end\n"
  end

  it "parses edit.erb.html" do
    parse("<h1>Editing foo</h1>

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
")
  end

  it "parses show.html.erb" do
    parse("<p>
  <b>Name:</b>
  <%=h @foo.name %>
</p>

<p>
  <b>Age:</b>
  <%=h @foo.age %>
</p>


<%= link_to 'Edit', edit_foo_path(@foo) %> |
<%= link_to 'Back', foos_path %>
")
  end

  it "does meta" do
    parse('<meta http-equiv="content-type" content="text/html;charset=UTF-8" />').convert.should ==
    "meta 'http-equiv' => 'content-type', :content => 'text/html;charset=UTF-8'\n"
  end
  
  it "parses JayTee's IE and DOCTYPE test file" do
    parse <<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!--[if IE]><link href="custom.css" rel="stylesheet" type="text/css" /><![endif]-->
<!--[if IE]><link href="custom.css" rel="stylesheet" type="text/css" /><![endif]-->
<script language="javascript" type="text/javascript"> /* <![CDATA[ */
var myJavascriptCode = 1; /*]]>*/ </script>
</head>
<body>
</body>
</html>
    HTML
  end
end
