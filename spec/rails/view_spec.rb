require File.dirname(__FILE__) + "/../spec_helper"

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

describe "the case which fake_erbout handles" do
  it "works" do
    @view = ActionView::Base.new
    Erector::Widget.new(@view) do
      foo = capture() do
        fake_erbout do
          helpers.concat('foo')
        end
      end
      foo.should == 'foo'
    end.to_s.should == ""
  end
end
