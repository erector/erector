require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe "indentation" do

  it "can detect newliney tags" do
    doc = Erector::Doc.new(StringIO.new(""), :add_newlines => true)
    doc.newliney("i").should == false
    doc.newliney("table").should == true
  end

  it "should not add newline for non-newliney tags" do
    Erector::Widget.new() do
      text "Hello, "
      b "World"
    end.add_newlines(true).to_s.should == "Hello, <b>World</b>"
  end
  
  it "should add newlines before open newliney tags" do
    Erector::Widget.new() do
      p "foo"
      p "bar"
    end.add_newlines(true).to_s.should == "<p>foo</p>\n<p>bar</p>\n"
  end
  
  it "should add newlines between text and open newliney tag" do
    Erector::Widget.new() do
      text "One"
      p "Two"
    end.add_newlines(true).to_s.should == "One\n<p>Two</p>\n"
  end
  
  it "should add newlines after end newliney tags" do
    Erector::Widget.new() do
      tr do
        td "cell"
      end
    end.add_newlines(true).to_s.should == "<tr>\n  <td>cell</td>\n</tr>\n"
  end
  
  it "should treat empty elements as start and end" do
    Erector::Widget.new() do
      p "before"
      br
      p "after"
    end.add_newlines(true).to_s.should == "<p>before</p>\n<br />\n<p>after</p>\n"
  end
  
  it "empty elements sets at_start_of_line" do
    Erector::Widget.new() do
      text "before"
      br
      p "after"
    end.add_newlines(true).to_s.should == "before\n<br />\n<p>after</p>\n"
  end

  it "will not insert extra space before/after input element" do
    # If dim memory serves, the reason for not adding spaces here is
    # because it affects/affected the rendering in browsers.
    Erector::Widget.new() do
      text 'Name'
      input :type => 'text'
      text 'after'
    end.add_newlines(true).to_s.should == 'Name<input type="text" />after'
  end
  
  it "will indent" do
    Erector::Widget.new() do
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
    end.add_newlines(true).to_s.should == <<END
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
  
  it "can turn off newlines" do
    Erector::Widget.new(:add_newlines => false) do
      text "One"
      p "Two"
    end.add_newlines(false).to_s.should == "One<p>Two</p>"
  end
  
end

