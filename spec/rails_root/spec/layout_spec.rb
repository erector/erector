require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")



describe ActionController::Base do
  class LayoutTestController < ActionController::Base
    # Let exceptions propagate rather than generating the usual error page.
    include ActionController::TestCase::RaiseActionExceptions

    # We need this, because we reference Views::Test::Needs below, and it
    # doesn't auto-load otherwise.

    require 'views/test/render_default.html.rb'

    layout :layout

    def layout
      case action_name
      when /erb_layout/ then 'erb_layout'
      when /erector_layout/ then 'erector_layout'
      else false
      end
    end

    def render_default(options={})
      render options.reverse_merge({ :template => 'test/render_default' })
    end

    def render_default_with_erb_layout
      render_default
    end

    def render_default_with_erector_layout
      render_default
    end

    def render_override_default_erb_layout
      render_default :layout => 'erector_layout'
    end

    def render_override_default_erector_layout
      render_default :layout => 'erb_layout'
    end

    def render_no_layout_instead_of_default_erb_layout
      render_default :layout => false
    end

    def render_default_with_needy_erector_layout
      @layout_need = 'needy'
      render_default
    end

    def render_widget_with_erb_layout
      render :widget => LayoutTestWidget
    end

    def render_widget_with_erector_layout
      render :widget => LayoutTestWidget
    end

    def render_widget_with_erb_nested_layout
      render :widget => LayoutTestWidget, :layout => 'erb_layout_with_nested_widget'
    end

    def render_widget_with_erector_nested_layout
      render :widget => LayoutTestWidget, :layout => 'erector_layout_with_nested_widget'
    end

  end

  class LayoutTestWidget < Erector::Widget
    def content
      text 'test content '
    end
  end

  def test_action(action)
    @response = LayoutTestController.action(action).call(Rack::MockRequest.env_for("/path"))[2]
    @response.body
  end

  describe "render in a controller with layout" do

    it "renders default erb layout with default template" do
      test_action(:render_default_with_erb_layout).should == "Default with erb layout"
    end

    it "renders default erector layout with default template" do
      test_action(:render_default_with_erector_layout).should == "Default with erector layout"
    end

    it "renders explicit erector layout instead of default erb with default template" do
      test_action(:render_override_default_erb_layout).should == "Default with erector layout"
    end

    it "renders explicit erb layout instead of default erector with default template" do
      test_action(:render_override_default_erector_layout).should == "Default with erb layout"
    end

    it "renders no layout with default template" do
      test_action(:render_no_layout_instead_of_default_erb_layout).should == "Default "
    end

    it "renders default erector layout with default template passing needs to layout" do
      test_action(:render_default_with_needy_erector_layout).should == "Default with needy layout"
    end

    it "renders widget with erb layout" do
      test_action(:render_widget_with_erb_layout).should == "test content with erb layout"
    end

    it "renders widget with erector layout" do
      test_action(:render_widget_with_erector_layout).should == "test content with erector layout"
    end

    it "renders widget with erb layout that has a nested widget" do
      test_action(:render_widget_with_erb_nested_layout).should == "Default nested in test content with erb layout"
    end

    it "renders widget with erector layout that has a nested widget" do
      test_action(:render_widget_with_erector_nested_layout).should == "Default nested in test content with erector layout"
    end

  end

end