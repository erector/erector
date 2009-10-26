require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe ActionController::Base do
  class TestWidgetController < ActionController::Base
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

    def render_colon_widget_with_explicit_assigns
      render :widget => TestWidget, :foobar => "foobar"
    end

    def render_colon_template
      @foo = "foo"
      render :template => "template_handler_specs/test_page.html.rb"
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
    @controller = TestWidgetController.new
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

  describe "#render :widget" do
    it "should render a widget with implicit assigns" do
      @request.action = "render_colon_widget_with_implicit_assigns"
      @controller.process(@request, @response)
      @response.body.should == "foobar"
    end

    it "should render a widget with explicit assigns" do
      @request.action = "render_colon_widget_with_explicit_assigns"
      @controller.process(@request, @response)
      @response.body.should == "foobar"
    end
  end

  describe "#render :template" do
    it "assigns instance variables, renders partials, and properly handles controllers with pluralized names" do
      @request.action = "render_colon_template"
      @controller.process(@request, @response)
      @response.body.strip.gsub("  ", "").gsub("\n", "").should == '<div class="page"><div class="partial">foo</div></div>'
    end
  end

  describe "#render :update" do
    it "should override RJS output_buffer changes" do
      @request.action = "render_rjs_with_widget"
      @controller.process(@request, @response)
      @response.body.should include("Element.insert")
    end
  end
end
