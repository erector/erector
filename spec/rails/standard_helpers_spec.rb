require File.dirname(__FILE__) + "/../spec_helper"

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
      pending("error_messages_for is broken")
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

  it "#image_tag" do
    Erector::Widget.new(@view) do
      image_tag("/foo")
    end.to_s.should == %{<img alt="Foo" src="/foo" />}
  end

  it "#image_tag with parameters" do
    Erector::Widget.new(@view) do
      image_tag("/foo", :id => "photo_foo", :class => "a_photo_class")
    end.to_s.should == %{<img alt="Foo" class="a_photo_class" id="photo_foo" src="/foo" />}
  end

  it "renders non-forgery-protected forms via form_tag" do
    pending("needs ActionView::capture to work")
    class << @view
      def protect_against_forgery?
        false
      end
    end

    Erector::Widget.new(@view) do
      form_tag("/foo") do
        p "I'm in a form"
      end
    end.to_s.should == "<form action=\"/foo\" method=\"post\"><p>I'm in a form</p></form>"
  end

  it "renders forgery-protected forms via form_tag" do
    pending("needs ActionView::capture to work")
    class << @view
      def protect_against_forgery?
        true
      end

      def request_forgery_protection_token

      end

      def form_authenticity_token
        "token"
      end
    end

    Erector::Widget.new(@view) do
      puts "starting"
      form_tag("/foo") do
        puts "start of block"
        p "I'm in a form"
      end
    end.to_s.should == "<form action=\"/foo\" method=\"post\"><div style=\"margin:0;padding:0\"><input name=\"\" type=\"hidden\" value=\"token\" /></div><p>I'm in a form</p></form>"
  end
end

