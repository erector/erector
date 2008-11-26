require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe Erector::Widget do
  class RailsSpecWidget < Erector::Widget

  end

  before(:each) do
    @view = ActionView::Base.new
    if @view.respond_to?(:output_buffer)
      @view.output_buffer = ""
    end
    # hook in model and add error messages
  end

  describe "#capture" do
    it "captures with an erector block" do
      captured = nil
      message = Erector::Widget.new(@view) do
        captured = @helpers.capture do
          h1 'capture me!'
        end
      end.to_s.should == ""
      captured.should == "<h1>capture me!</h1>"
    end
  end

  context "with errors" do
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
  end

  describe "#link_to" do
    it "renders the link" do
      RailsSpecWidget.new(@view) do
        link_to 'This&that', '/foo?this=1&amp;that=1'
      end.to_s.should == "<a href=\"/foo?this=1&amp;that=1\">This&amp;that</a>"
    end
  end

  describe "#image_tag" do
    it "renders" do
      RailsSpecWidget.new(@view) do
        image_tag("/foo")
      end.to_s.should == %{<img alt="Foo" src="/foo" />}
    end

    context "with parameters" do
      it "renders" do
        RailsSpecWidget.new(@view) do
          image_tag("/foo", :id => "photo_foo", :class => "a_photo_class")
        end.to_s.should == %{<img alt="Foo" class="a_photo_class" id="photo_foo" src="/foo" />}
      end
    end
  end

  context "when forgery protection is turned off" do
    it "renders non-forgery-protected forms via form_tag" do
      class << @view
        def protect_against_forgery?
          false
        end
      end

      RailsSpecWidget.new(@view) do
        form_tag("/foo") do
          p "I'm in a form"
        end
      end.to_s.should == "<form action=\"/foo\" method=\"post\"><p>I'm in a form</p></form>"
    end
  end

  context "when forgery protection is turned on" do
    it "renders forgery-protected forms via form_tag" do
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

      RailsSpecWidget.new(@view) do
        form_tag("/foo") do
          p "I'm in a form"
        end
      end.to_s.should == "<form action=\"/foo\" method=\"post\"><div style=\"margin:0;padding:0\"><input name=\"\" type=\"hidden\" value=\"token\" /></div><p>I'm in a form</p></form>"
    end
  end
end
