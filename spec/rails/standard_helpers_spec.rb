require File.dirname(__FILE__) + "/../spec_helper"

#require ActiveRecord::

describe "a view" do
  before(:each) do
    @view = ActionView::Base.new
    # hook in model and add error messages
  end

  describe "with errors" do
    before(:each) do
      class DummyView < ActionView::Base
        attr_accessor :model
      end

      class DummyModel
        # not sure what the best way is to mock out a model without
        # needing a database.  But here's my attempt.
        attr_accessor :errors

        def self.human_attribute_name(attribute)
          attribute.to_s.capitalize
        end
      end
      
      @view = DummyView.new()
      model = DummyModel.new()
      model.errors = ActiveRecord::Errors.new(model)
      model.errors.add(:field, 'too silly')
      @view.model = model
    end
    
    it "was set up correctly" do
      @view.model.errors.full_messages.join(',').should == "Field too silly"
    end

    it "renders error messages" do
      message = Erector::Widget.new(@view) do
        error_messages_for(:model)
      end.to_s
      message.should include("too silly")
      message.should include("1 error")
    end
    
  end

  it "renders links" do
    Erector::Widget.new(@view) do
      link_to 'This&that', '/foo?this=1&amp;that=1'
    end.to_s.should == "<a href=\"/foo?this=1&amp;that=1\">This&amp;that</a>"
  end
end

