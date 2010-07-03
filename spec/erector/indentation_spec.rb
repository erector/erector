require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe "indentation" do
  include Erector::Mixin

  it "can detect newliney tags" do
    widget = ::Erector.inline
    widget.instance_eval do
      @prettyprint = true
    end
    widget.send(:newliney?, "i").should == false
    widget.send(:newliney?, "table").should == true
  end

  it "should not add newline for non-newliney tags" do
    Erector.inline do
      text "Hello, "
      b "World"
    end.to_pretty.should == "Hello, <b>World</b>"
  end

  it "should add newlines before open newliney tags" do
    Erector.inline do
      p "foo"
      p "bar"
    end.to_pretty.should == "<p>foo</p>\n<p>bar</p>\n"
  end

  it "should add newlines between text and open newliney tag" do
    Erector.inline do
      text "One"
      p "Two"
    end.to_pretty.should == "One\n<p>Two</p>\n"
  end

  it "should add newlines after end newliney tags" do
    Erector.inline do
      tr do
        td "cell"
      end
    end.to_pretty.should == "<tr>\n  <td>cell</td>\n</tr>\n"
  end

  it "should treat empty elements as start and end" do
    Erector.inline do
      p "before"
      br
      p "after"
    end.to_pretty.should == "<p>before</p>\n<br />\n<p>after</p>\n"
  end

  it "empty elements sets at_start_of_line" do
    Erector.inline do
      text "before"
      br
      p "after"
    end.to_pretty.should == "before<br />\n<p>after</p>\n"
  end

  it "will not insert extra space before/after input element" do
    # If dim memory serves, the reason for not adding spaces here is
    # because it affects/affected the rendering in browsers.
    Erector.inline do
      text 'Name'
      input :type => 'text'
      text 'after'
    end.to_pretty.should == 'Name<input type="text" />after'
  end

  it "will indent" do
    Erector.inline do
      html do
        head do
          title "hi"
        end
        body do
          div do
            p "paragraph"
          end
        end
      end
    end.to_pretty.should == <<END
<html>
  <head>
    <title>hi</title>
  </head>
  <body>
    <div>
      <p>paragraph</p>
    </div>
  </body>
</html>
END
  end

  it "preserves indentation for sub-rendered widgets" do
    tea = Erector.inline do
      div do
        p "oolong"
      end
    end
    cup = Erector.inline do
      div do
        p "fine china"
        widget tea
      end
    end

    cup.to_pretty.should == <<END
<div>
  <p>fine china</p>
  <div>
    <p>oolong</p>
  </div>
</div>
END
  end

  # see http://github.com/pivotal/erector/issues/#issue/5
  it "indents scripts properly" do
    pending 
    Erector.inline do
      html :xmlns => 'http://www.w3.org/1999/xhtml' do
        head do
          javascript "Cufon.replace('#content');"
          javascript '$(document).ready(function(){  $(document).pngFix(); });'
        end
        body do
        end
      end
    end.to_pretty.should == <<-HTML
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <script type="text/javascript">
// <![CDATA[
Cufon.replace('#content');
// ]]>
    </script>
    <script type="text/javascript">
// <![CDATA[
$(document).ready(function(){  $(document).pngFix(); });
// ]]>
    </script>
  </head>
  <body></body>
</html>
    HTML
  end

  it "can turn off newlines" do
    erector do
      text "One"
      p "Two"
    end.should == "One<p>Two</p>"
  end

  it "can turn newlines on and off" do
    widget = Erector.inline do
      text "One"
      p "Two"
    end
    widget.to_html.should == "One<p>Two</p>"
    widget.to_pretty.should == "One\n<p>Two</p>\n"
    widget.to_html.should == "One<p>Two</p>"
  end

  it "can turn on newlines via to_pretty" do
    widget = Erector.inline do
      text "One"
      p "Two"
    end.to_pretty.should == "One\n<p>Two</p>\n"
  end

  it "can turn newlines on/off via global variable" do
    erector { br }.should == "<br />"
    Erector::Widget.prettyprint_default = true
    erector { br }.should == "<br />\n"
    Erector::Widget.prettyprint_default = false
    erector { br }.should == "<br />"
  end

  describe ":max_length" do
    it "wraps after N characters" do
      Erector.inline do
        div "the quick brown fox jumps over the lazy dog"
      end.to_html(:max_length => 20).should ==
              "<div>the quick brown\n" +
                      "fox jumps over the\n" +
                      "lazy dog</div>"
    end

    it "preserves pretty indent" do
      Erector.inline do
        div "the quick brown fox jumps over the lazy dog"
      end.to_pretty(:max_length => 20).should ==
              "<div>the quick brown\n" +
                      "  fox jumps over the\n" +
                      "  lazy dog</div>\n"
    end

    it "preserves raw strings" do
      Erector.inline do
        div raw("the quick <brown> fox <jumps> over the lazy dog")
      end.to_html(:max_length => 20).should ==
              "<div>the quick\n" +
                      "<brown> fox <jumps>\n" +
                      "over the lazy dog\n" +
                      "</div>"
    end
  end
end
