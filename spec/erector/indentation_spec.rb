require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe "indentation" do

  it "can detect newliney tags" do
    widget = ::Erector::Widget.new
    widget.instance_eval do 
      @prettyprint = true
    end
    widget.newliney("i").should == false
    widget.newliney("table").should == true
  end

  it "should not add newline for non-newliney tags" do
    Erector::Widget.new() do
      text "Hello, "
      b "World"
    end.to_pretty.should == "Hello, <b>World</b>"
  end
  
  it "should add newlines before open newliney tags" do
    Erector::Widget.new() do
      p "foo"
      p "bar"
    end.to_pretty.should == "<p>foo</p>\n<p>bar</p>\n"
  end
  
  it "should add newlines between text and open newliney tag" do
    Erector::Widget.new() do
      text "One"
      p "Two"
    end.to_pretty.should == "One\n<p>Two</p>\n"
  end
  
  it "should add newlines after end newliney tags" do
    Erector::Widget.new() do
      tr do
        td "cell"
      end
    end.to_pretty.should == "<tr>\n  <td>cell</td>\n</tr>\n"
  end
  
  it "should treat empty elements as start and end" do
    Erector::Widget.new() do
      p "before"
      br
      p "after"
    end.to_pretty.should == "<p>before</p>\n<br />\n<p>after</p>\n"
  end
  
  it "empty elements sets at_start_of_line" do
    Erector::Widget.new() do
      text "before"
      br
      p "after"
    end.to_pretty.should == "before\n<br />\n<p>after</p>\n"
  end

  it "will not insert extra space before/after input element" do
    # If dim memory serves, the reason for not adding spaces here is
    # because it affects/affected the rendering in browsers.
    Erector::Widget.new() do
      text 'Name'
      input :type => 'text'
      text 'after'
    end.to_pretty.should == 'Name<input type="text" />after'
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
    tea = Erector::Widget.new do
      div do
        p "oolong"
      end
    end
    cup = Erector::Widget.new do
      div do
        p "fine china"
        tea.write_via(self)
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
  
  it "can turn off newlines" do
    Erector::Widget.new() do
      text "One"
      p "Two"
    end.to_s.should == "One<p>Two</p>"
  end
  
  it "can turn newlines on and off" do
    widget = Erector::Widget.new() do
      text "One"
      p "Two"
    end
    widget.to_s.should == "One<p>Two</p>"
    widget.to_pretty.should == "One\n<p>Two</p>\n"
    widget.to_s.should == "One<p>Two</p>"
  end
  
  it "can turn on newlines via to_pretty" do
    widget = Erector::Widget.new() do
      text "One"
      p "Two"
    end.to_pretty.should == "One\n<p>Two</p>\n"
  end
  
  it "can turn newlines on/off via global variable" do
    Erector::Widget.new { br }.to_s.should == "<br />"
    Erector::Widget.prettyprint_default = true
    Erector::Widget.new { br }.to_s.should == "<br />\n"
    Erector::Widget.prettyprint_default = false
    Erector::Widget.new { br }.to_s.should == "<br />"
  end
  
end

