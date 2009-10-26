require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")

describe ActionController::Base do
  class TestController < ActionController::Base
    # Let exceptions propagate rather than generating the usual error page.
    include ActionController::TestCase::RaiseActionExceptions

    def render_widget_with_implicit_assigns
      @foobar = "foobar"
      render_widget TestWidget
    end

    def render_widget_with_explicit_assigns
      render_widget TestWidget, :foobar => "foobar"
    end

    def render_widget_class
      @foobar = "foobar"
      render :widget => TestWidget
    end

    def render_widget_instance
      render :widget => TestWidget.new(:foobar => "foobar")
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

    def render_erb_from_erector
      @foobar = "foobar"
      render :template => "test/erb_from_erector.html.rb"
    end

    def render_erector_from_erb
      @foobar = "foobar"
      render :template => "test/erector_from_erb.html.erb"
    end

    def render_reserved_variable
      @foobar = "foobar"
      @indentation = true
      render :template => "test/implicit_assigns.html.rb"
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

  def test_action(action)
    @request.action = action.to_s
    @controller.process(@request, @response)
    @response.body
  end

  describe "#render_widget" do
    it "should render a widget with implicit assigns" do
      test_action(:render_widget_with_implicit_assigns).should == "foobar"
    end

    it "should render a widget with explicit assigns" do
      test_action(:render_widget_with_explicit_assigns).should == "foobar"
    end
  end

  describe "#render" do
    it "should render a widget class with implicit assigns" do
      test_action(:render_widget_class).should == "foobar"
    end

    it "should render a widget instance with explicit assigns" do
      test_action(:render_widget_instance).should == "foobar"
    end

    it "should render a template with implicit assigns" do
      test_action(:render_template_with_implicit_assigns).should == "foobar"
    end

    it "should not include protected instance variables in assigns" do
      test_action(:render_template_with_protected_instance_variable).should == ""
    end

    it "should render a template without a .html format included" do
      test_action(:render_bare_rb).should == "Bare"
    end

    it "should render a template which uses partials" do
      test_action(:render_template_with_partial).should == "Partial foobar"
    end

    it "should render an erector widget which uses an ERB partial'" do
      test_action(:render_erb_from_erector).should == "Partial foobar"
    end

    it "should render an ERB template which uses an erector widget partial" do
      test_action(:render_erector_from_erb).should == "Partial foobar"
    end

    it "should render a default template" do
      test_action(:render_default).should == "Default foobar"
    end

    it "should raise if a reserved variable is implicitly assigned" do
      proc { test_action(:render_reserved_variable) }.should raise_error(ActionView::TemplateError, /indentation is a reserved variable name/)
    end

    it "should render updates while overriding RJS output_buffer changes" do
      test_action(:render_rjs_with_widget).should include("Element.insert")
    end
  end
end
