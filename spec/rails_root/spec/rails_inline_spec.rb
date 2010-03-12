require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe "Erector.inline" do
  it "should allow view helpers to be called" do
    view = ActionView::Base.new
    view.output_buffer = ""
    view.instance_eval do
      Erector.inline do
        image_tag! "test.gif"
      end.to_s.should == '<img alt="Test" src="/images/test.gif" />'
    end
  end
end

describe "Erector::RailsWidget.inline" do
  it "should return an InlineRailsWidget" do
    inline_widget = Erector::RailsWidget.inline
    inline_widget.should be_a Erector::RailsWidget
    inline_widget.should be_a Erector::Inline
  end

  it "should pass the block to the inline widget" do
    Erector::RailsWidget.inline do
      text "inline"
    end.to_s.should == "inline"
  end
end
