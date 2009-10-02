require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::InlineRailsWidget do
  before(:each) do
    @view = ActionView::Base.new
    if @view.respond_to?(:output_buffer)
      @view.output_buffer = ""
    end
    # hook in model and add error messages
  end

  it "it's block is evaluated in the widget's context, including helpers" do      
    @sample_instance_variable = "yum"
    sample_bound_variable = "yay"
    Erector::InlineRailsWidget.new do
      @sample_instance_variable.should be_nil
      sample_bound_variable.should == "yay"
      image_tag "you can call helper methods from in here.gif"
      # puts "uncomment this to prove this is being executed"
    end.to_s(:helpers => @view).should == "<img alt=\"You can call helper methods from in here\" src=\"/images/you can call helper methods from in here.gif\" />"
    
  end
  
  it "the 'inline' method returns an InlineRailsWidget" do
    Erector::RailsWidget.inline.should be_a Erector::InlineRailsWidget
  end
end

