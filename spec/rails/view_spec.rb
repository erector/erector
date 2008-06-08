require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe "a view" do
  before(:each) do
    @view = ActionView::Base.new
    # hook in model and add error messages
  end

  it "can capture with an erector block" do
    pending("not sure why this is failing if form_tag is working")
    message = Erector::Widget.new(@view) do
      captured = @helpers.capture do
        h1 'capture me!'
      end
      captured.should == "<h1>capture me!</h1>"
    end.to_s.should == ""
  end

end
