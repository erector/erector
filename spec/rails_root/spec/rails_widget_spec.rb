require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::Rails::WidgetExtensions do
  before(:each) do
    @view = ActionView::Base.new
  end

  it "should be set up with the same output buffer as rails" do
    Erector.inline do
      output.buffer.should === parent.output_buffer
    end.to_s(:parent => @view)
  end

  it "should get a new output buffer every time" do
    one = Erector::Rails.render(Erector.inline { text "foo" }, @view)
    two = Erector::Rails.render(Erector.inline { text "foo" }, @view)
    one.should == "foo"
    two.should == "foo"
  end

  describe "#capture" do
    it "captures parent output" do
      captured = nil
      Erector.inline do
        captured = capture do
          parent.concat "capture me!"
        end
      end.to_s(:parent => @view).should == ""
      captured.should == "capture me!"
    end

    it "captures with an erector block" do
      captured = nil
      Erector.inline do
        captured = capture do
          text 'capture me!'
        end
      end.to_s(:parent => @view).should == ""
      captured.should == "capture me!"
    end

    it "captures erector output when called via parent" do
      Erector.inline do
        text "A"
        c = parent.capture do
          text "C"
        end
        text "B"
        text c
      end.to_s(:parent => @view).should == "ABC"
    end

    it "returns a safe string" do
      captured = nil
      Erector.inline do
        captured = capture {}
      end.to_s(:parent => @view).should == ""
      captured.should be_html_safe
    end
  end

  describe "escaping" do
    it "escapes non-safe strings" do
      Erector.inline { text "<>&" }.to_s.should == "&lt;&gt;&amp;"
    end

    it "does not escape safe strings" do
      Erector.inline { text "<>&".html_safe }.to_s.should == "<>&"
    end

    it "returns safe strings from to_s" do
      Erector.inline { text "foobar" }.to_s.should be_html_safe
    end

    it "returns safe strings from capture" do
      captured = nil
      Erector.inline do
        captured = capture {}
      end.to_s
      captured.should be_html_safe
    end
  end
end
