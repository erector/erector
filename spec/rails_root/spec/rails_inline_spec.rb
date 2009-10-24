require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::InlineRailsWidget do
  context "new" do
    it "should accept a block" do
      Erector::InlineRailsWidget.new do
        text "inline"
      end.to_s.should == "inline"
    end

    it "should evaluate the block in the widget's context" do
      @sample_instance_variable = "yum"
      sample_bound_variable = "yay"
      Erector::InlineRailsWidget.new do
        @sample_instance_variable.should == nil
        sample_bound_variable.should == "yay"
        text "inline"
      end.to_s.should == "inline"
    end

    it "should allow view helpers to be called" do
      view = ActionView::Base.new
      view.output_buffer = "" if view.respond_to?(:output_buffer)
      view.instance_eval do
        Erector::InlineRailsWidget.new do
          image_tag "test.gif"
        end.to_s.should == '<img alt="Test" src="/images/test.gif" />'
      end
    end
  end
end

describe "Erector::RailsWidget.inline" do
  it "should return an InlineRailsWidget" do
    Erector::RailsWidget.inline.should be_a Erector::InlineRailsWidget
  end

  it "should pass the block to the inline widget" do
    Erector::RailsWidget.inline do
      text "inline"
    end.to_s.should == "inline"
  end
end
