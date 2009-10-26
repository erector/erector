require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe ActionController::Base do
  class TestController < ActionController::Base
    def render_widget_with_implicit_assigns
      @foobar = "foobar"
      render_widget TestWidget
    end

    def render_widget_with_explicit_assigns
      render_widget TestWidget, :foobar => "foobar"
    end

    def render_colon_widget_with_implicit_assigns
      @foobar = "foobar"
      render :widget => TestWidget
    end

    def render_template_with_implicit_assigns
      @foobar = "foobar"
      render :template => "test/implicit_assigns.html.rb"
    end

    def render_template_with_protected_instance_variable
      render :template => "test/protected_instance_variable.html.rb"
    end

    def render_bare_rb
      render :template => "test/bare.rb"
    end

    def render_default
      @foobar = "foobar"
    end

    def render_template_with_partial
      @foobar = "foobar"
      render :template => "test/render_partial.html.rb"
    end

    def render_rjs_with_widget
      render :update do |page|
        page.insert_html :top, 'foobar', TestFormWidget.new(:parent => self).to_s
      end
    end
  end

  class TestWidget < Erector::RailsWidget
    def content
      text @foobar
    end
  end

  class TestFormWidget < Erector::RailsWidget
    def content
      form_tag('/') do
        h1 "Create a foo"
        rawtext text_field_tag(:name)
      end
    end
  end

  before do
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  describe "#render_widget" do
    it "should render a widget with implicit assigns" do
      @request.action = "render_widget_with_implicit_assigns"
      @controller.process(@request, @response)
      @response.body.should == "foobar"
    end

    it "should render a widget with explicit assigns" do
      @request.action = "render_widget_with_explicit_assigns"
      @controller.process(@request, @response)
      @response.body.should == "foobar"
    end
  end

  describe "#render" do
    it "should render a widget with implicit assigns" do
      @request.action = "render_colon_widget_with_implicit_assigns"
      @controller.process(@request, @response)
      @response.body.should == "foobar"
    end

    it "should render a template with implicit assigns" do
      @request.action = "render_template_with_implicit_assigns"
      @controller.process(@request, @response)
      @response.body.should == "foobar"
    end

    it "should not include protected instance variables in assigns" do
      @request.action = "render_template_with_protected_instance_variable"
      @controller.process(@request, @response)
      @response.body.should == ""
    end

    it "should render a template without a .html format included" do
      @request.action = "render_bare_rb"
      @controller.process(@request, @response)
      @response.body.should == "Bare"
    end

    it "should render a template which uses partials" do
      @request.action = "render_template_with_partial"
      @controller.process(@request, @response)
      @response.body.should == "Partial foobar"
    end

    it "should render a default template" do
      @request.action = "render_default"
      @controller.process(@request, @response)
      @response.body.should == "Default foobar"
    end

    it "should render updates while overriding RJS output_buffer changes" do
      @request.action = "render_rjs_with_widget"
      @controller.process(@request, @response)
      @response.body.should include("Element.insert")
    end
  end
end
