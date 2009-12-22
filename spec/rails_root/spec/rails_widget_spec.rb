require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::Rails::WidgetExtensions do
  before(:each) do
    @view = ActionView::Base.new
    @view.output_buffer = ""
  end

  describe "#capture" do
    it "returns a RawString" do
      captured = nil
      Erector.inline do
        captured = capture {}
      end.to_s(:parent => @view).should == ""
      captured.should be_a_kind_of Erector::RawString
    end

    it "captures helper output" do
      captured = nil
      Erector.inline do
        captured = capture do
          helpers.concat "capture me!"
        end
      end.to_s(:parent => @view, :helpers => @view).should == ""
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
  end

  describe "escaping" do
    it "escapes non-safe strings" do
      Erector.inline { text "<>&" }.to_s.should == "&lt;&gt;&amp;"
    end

    it "does not escape safe strings" do
      Erector.inline { text "<>&".html_safe! }.to_s.should == "<>&"
    end

    it "returns safe strings from to_s" do
      Erector.inline { text "foobar" }.to_s.html_safe?.should == true
    end

    it "returns safe strings from capture" do
      captured = nil
      Erector.inline do
        captured = capture {}
      end.to_s
      captured.html_safe?.should == true
    end
  end
end
