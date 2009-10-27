require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::Widget do
  it "provides access to instance variables from the calling context" do
    @var = "yay"
    Erector::Widget.new { @var.should == "yay"; @var = "yum" }.to_s
    @var.should == "yum"
  end

  it "provides access to bound variables from the calling context" do
    var = "yay"
    Erector::Widget.new { var.should == "yay"; var = "yum" }.to_s
    var.should == "yum"
  end

  it "doesn't provide access to Erector methods" do
    Erector::Widget.new { lambda { text "yay" }.should raise_error(NoMethodError) }.to_s
  end
end

describe Erector::Inline do
  it "returns an InlineWidget" do
    Erector.inline.should be_a_kind_of(Erector::InlineWidget)
  end

  it "doesn't provide access to instance variables from the calling context" do
    @var = "yay"
    Erector.inline { text @var }.to_s.should == ""
  end

  it "provides access to bound variables from the calling context" do
    var = "yay"
    Erector.inline { text var }.to_s.should == "yay"
  end

  it "provides access to explicit assigns" do
    Erector.inline(:var => "yay") { text @var }.to_s.should == "yay"
  end

  it "provides access to methods from the calling context" do
    def helper
      "yay"
    end

    Erector.inline { text helper }.to_s.should == "yay"
  end
end

describe Erector::Mixin do
  include Erector::Mixin

  it "doesn't provide access to instance variables from the calling context" do
    @var = "yay"
    erector { text @var }.should == ""
  end

  it "provides access to bound variables from the calling context" do
    var = "yay"
    erector { text var }.should == "yay"
  end

  it "provides access to methods from the calling context" do
    def helper
      "yay"
    end

    erector { text helper }.should == "yay"
  end
end
