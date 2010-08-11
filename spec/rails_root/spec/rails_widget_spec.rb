require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::Rails do
  include Erector::Mixin

  before(:each) do
    @view = ActionView::Base.new
  end

  def test_render(&block)
    Erector::Rails.render(Erector.inline(&block), @view)
  end

  it "should be set up with the same output buffer as rails" do
    test_render { output.buffer.should === parent.output_buffer }
  end

  it "should get a new output buffer every time" do
    one = test_render { text "foo" }
    two = test_render { text "foo" }
    one.should == "foo"
    two.should == "foo"
  end

  describe "#capture" do
    it "captures parent output" do
      captured = nil
      test_render do
        captured = capture do
          parent.concat "capture me!"
        end
      end.should == ""
      captured.should == "capture me!"
    end

    it "captures with an erector block" do
      captured = nil
      test_render do
        captured = capture do
          text 'capture me!'
        end
      end.should == ""
      captured.should == "capture me!"
    end

    it "captures erector output when called via parent" do
      test_render do
        text "A"
        c = parent.capture do
          text "C"
        end
        text "B"
        text c
      end.should == "ABC"
    end

    it "returns a safe string" do
      captured = nil
      test_render do
        captured = capture {}
      end.should == ""
      captured.should be_html_safe
    end
  end

  describe "escaping" do
    it "escapes non-safe strings" do
      erector { text "<>&" }.should == "&lt;&gt;&amp;"
    end

    it "does not escape safe strings" do
      erector { text "<>&".html_safe }.should == "<>&"
    end

    it "returns safe strings from capture" do
      captured = nil
      erector do
        captured = capture {}
      end
      captured.should be_html_safe
    end
  end
end
