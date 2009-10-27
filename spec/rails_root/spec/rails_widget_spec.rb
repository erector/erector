require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::RailsWidget do
  before(:each) do
    @view = ActionView::Base.new
    @view.output_buffer = ""
  end

  describe "#capture" do
    it "returns a RawString" do
      captured = nil
      Erector::RailsWidget.inline do
        captured = capture {}
      end.to_s(:parent => @view).should == ""
      captured.should be_a_kind_of Erector::RawString
    end

    it "captures helper output" do
      captured = nil
      Erector::RailsWidget.inline do
        captured = capture do
          helpers.concat "capture me!"
        end
      end.to_s(:parent => @view, :helpers => @view).should == ""
      captured.should == "capture me!"
    end

    it "captures with an erector block" do
      captured = nil
      Erector::RailsWidget.inline do
        captured = capture do
          text 'capture me!'
        end
      end.to_s(:parent => @view).should == ""
      captured.should == "capture me!"
    end
  end
end
