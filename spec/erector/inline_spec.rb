require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe Erector::Widget do
  it "provides access to instance variables from the calling context" do
    @var = "yay"
    Erector::Widget.new { @var.should == "yay"; @var = "yum" }.to_html
    @var.should == "yum"
  end

  it "provides access to bound variables from the calling context" do
    var = "yay"
    Erector::Widget.new { var.should == "yay"; var = "yum" }.to_html
    var.should == "yum"
  end

  it "doesn't provide access to Erector methods" do
    Erector::Widget.new { lambda { text "yay" }.should raise_error(NoMethodError) }.to_html
  end

  describe ".inline" do
    it "returns an instance with Erector::Inline mixed in" do
      widget_subclass = Class.new(Erector::Widget)
      widget_subclass.ancestors.should_not include(Erector::Inline)

      inlined_instance = widget_subclass.inline
      inlined_instance.class.ancestors.should include(widget_subclass)
      inlined_instance.class.ancestors.should include(Erector::Inline)
    end
  end
end

describe Erector::Inline do
  it "returns an InlineWidget" do
    Erector.inline.should be_a_kind_of(Erector::InlineWidget)
  end

  it "doesn't provide access to instance variables from the calling context" do
    @var = "yay"
    Erector.inline { text @var }.to_html.should == ""
  end

  it "provides access to bound variables from the calling context" do
    var = "yay"
    Erector.inline { text var }.to_html.should == "yay"
  end

  it "provides access to explicit assigns" do
    Erector.inline(:var => "yay") { text @var }.to_html.should == "yay"
  end

  it "provides access to methods from the calling context" do
    def helper
      "yay"
    end

    Erector.inline { text helper }.to_html.should == "yay"
  end

  describe "#call_block" do
    it "calls the block with a pointer to self" do
      x = Erector::InlineWidget.new do |y|
        element "arg", y.object_id
        element "self", self.object_id
      end

      # inside the block...
      x.to_html.should ==
        "<arg>#{x.object_id}</arg>" + # the argument is the child
        "<self>#{x.object_id}</self>" # and self is also the child
    end
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
