require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::Rails::FormBuilder do
  describe ".parent_builder_class" do
    it "defaults to ActionView::Base.default_form_builder" do
      Erector::Rails::FormBuilder.parent_builder_class.should == ActionView::Base.default_form_builder
    end
  end

  describe ".wrapping" do
    it "returns self when passed nil" do
      Erector::Rails::FormBuilder.wrapping(nil).should == Erector::Rails::FormBuilder
    end

    it "returns a FormBuilder subclass with the specified parent_builder_class" do
      my_form_builder = Class.new(ActionView::Base.default_form_builder)
      Erector::Rails::FormBuilder.wrapping(my_form_builder).parent_builder_class.should == my_form_builder
      Erector::Rails::FormBuilder.parent_builder_class.should == ActionView::Base.default_form_builder
    end
  end
end
