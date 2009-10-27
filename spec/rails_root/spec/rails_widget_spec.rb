require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::RailsWidget do
  before(:each) do
    @view = ActionView::Base.new
    @view.output_buffer = ""
  end

  describe "#capture" do
    it "captures with an erector block" do
      captured = nil
      Erector::RailsWidget.inline(:parent => @view) do
        captured = parent.capture do
          h1 'capture me!'
        end
      end.to_s.should == ""
      captured.should == "<h1>capture me!</h1>"
    end
  end
end
