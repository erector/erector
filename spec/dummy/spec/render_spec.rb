require 'spec_helper'

describe ActionController::Base do
  class TestController < ActionController::Base
    # Let exceptions propagate rather than generating the usual error page.
    include ActionController::TestCase::RaiseActionExceptions

    def render_widget_class
      @foobar = "foobar"
      render :widget => TestWidget
    end

    def render_widget_with_ignored_controller_variables
      @foo = "foo"
      @baz = "baz"
      render :widget => NeedsWidget
    end

    def render_widget_with_extra_controller_variables
      with_ignoring_extra_controller_assigns(NeedsWidget, false) do
        @foo = "foo"
        @baz = "baz"
        render :widget => NeedsWidget
      end
    end

    def render_widget_instance
      render :widget => TestWidget.new(:foobar => "foobar")
    end

    def render_with_content_method
      render :widget => TestWidget, :content_method_name => :content_method
    end

    def render_with_rails_options
      render :widget => TestWidget, :status => 500, :content_type => "application/json"
    end

    def render_template_with_implicit_assigns
      @foobar = "foobar"
      render :template => "test/implicit_assigns", :handlers => [:rb]
    end

    def render_template_with_protected_instance_variable
      render :template => "test/protected_instance_variable", :handlers => [:rb]
    end

    def render_template_with_excess_variables
      with_ignoring_extra_controller_assigns(Views::Test::Needs, false) do
        @foobar = "foobar"
        @barfoo = "barfoo"
        render :template => 'test/render_default', :handlers => [:rb]
      end
    end

    def render_needs_template_with_excess_variables
      with_ignoring_extra_controller_assigns(Views::Test::Needs, false) do
        @foobar = "foobar"
        @barfoo = "barfoo"
        render :template => 'test/needs', :handlers => [:rb]
      end
    end

    def with_ignoring_extra_controller_assigns(klass, value)
      old_value = klass.ignore_extra_controller_assigns
      begin
        klass.ignore_extra_controller_assigns = value
        yield
      ensure
        klass.ignore_extra_controller_assigns = old_value
      end
    end

    def render_needs_template_with_excess_variables_and_ignoring_extras
      @foobar = "foobar"
      @barfoo = "barfoo"
      render :template => 'test/needs', :handlers => [:rb]
    end

    def render_needs_subclass_template_with_excess_variables_and_ignoring_extras
      @foobar = "foobar"
      @barfoo = "barfoo"
      render :template => 'test/needs_subclass', :handlers => [:rb]
    end

    def render_bare_rb
      render :template => "test/bare", :handlers => [:rb], :bare => true
    end

    def render_default
      @foobar = "foobar"
    end

    def render_template_with_partial
      @foobar = "foobar"
      render :template => "test/render_partial", :handlers => [:rb]
    end

    def render_erb_from_erector
      @foobar = "foobar"
      render :template => "test/erb_from_erector", :handlers => [:rb]
    end

    def render_erector_from_erb
      @foobar = "foobar"
      render :template => "test/erector_from_erb", :handlers => [:erb]
    end

    def render_erector_with_locals_from_erb
      @local_foo = "hihi"
      @local_bar = "byebye"
      render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
    end

    def render_erector_with_helpers_from_erb
      render :template => 'test/erector_with_helpers_from_erb', :handlers => [:erb]
    end

    def render_erector_with_locals_from_erb_defaulted
      @local_foo = "hihi"
      render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
    end

    def render_erector_with_locals_from_erb_override
      @foo       = "globalfoo"
      @local_foo = "localfoo"
      render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
    end

    def render_erector_with_locals_from_erb_not_needed
      @local_foo = "localfoo"
      @local_baz = "unneeded"
      render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
    end

    def render_erector_partial_with_unneeded_controller_variables
      @local_foo = "localfoo"
      @baz       = "unneeded"
      render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
    end

    def with_controller_assigns_propagate_to_partials(klass, value)
      old_value = klass.controller_assigns_propagate_to_partials
      begin
        klass.controller_assigns_propagate_to_partials = value
        yield
      ensure
        klass.controller_assigns_propagate_to_partials = old_value
      end
    end

    def render_erector_partial_without_controller_variables
      with_controller_assigns_propagate_to_partials(Views::Test::PartialWithLocals, false) do
        @local_foo = "localfoo"
        @bar       = "barbar"
        render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
      end
    end

    def render_with_needs
      @foo = "foo"
      @bar = "bar"
      render :widget => NeedsWidget
    end

    def render_with_widget_as_layout
      render :layout => "layouts/widget_as_layout"
    end

    def render_default_widget_with_layout
      @widget_content = "widget content"
      @layout_content = "layout content"
    end

    def render_default_erb_with_layout
      @erb_content    = "erb content"
      @layout_content = "layout content"
    end

    def render_with_widget_as_layout_and_vars
      @before = "Breakfast"
      @during = "Lunch"
      @after  = "Dinner"
      render :template => "test/render_with_widget_as_layout", :layout => "layouts/widget_as_layout"
    end

    def render_with_needs_name_same_as_partial_name
      render template: 'test/users', layout: false
    end

    def render_with_widget_as_layout_using_content_for
      render :template => "test/render_with_widget_as_layout_using_content_for", :layout => "layouts/widget_as_layout"
    end

    def render_virtual_path
      render template: "test/render_virtual_path", layout: false
    end
  end

  class TestWidget < Erector::Widget
    def content
      text @foobar
    end

    def content_method
      text "content_method"
    end
  end

  class TestFormWidget < Erector::Widget
    def content
      form_tag('/') do
        h1 "Create a foo"
        rawtext text_field_tag(:name)
      end
    end
  end

  class NeedsWidget < Erector::Widget
    needs :foo, :bar => true

    def content
      text "foo #{@foo} bar #{@bar}"
    end
  end

  def test_action(action)
    @response = TestController.action(action).call(Rack::MockRequest.env_for("/path"))[2]
    @response.body
  end

  describe "#render" do
    it "should render a widget class with implicit assigns" do
      test_action(:render_widget_class).should == "foobar"
    end

    it "should render a widget instance with explicit assigns" do
      test_action(:render_widget_instance).should == "foobar"
    end

    it "should render a widget class with implicit assigns and ignoring extra variables" do
      test_action(:render_widget_with_ignored_controller_variables).should == "foo foo bar true"
    end

    it "should raise when rendering a widget class with implicit assigns and too many variables" do
      proc { test_action(:render_widget_with_extra_controller_variables) }.should raise_error(ArgumentError, /Excess parameters?.*: .*baz/)
    end

    it "should render a specific content method" do
      test_action(:render_with_content_method).should == "content_method"
    end

    it "should pass rails options to base render method" do
      test_action(:render_with_rails_options)
      @response.response_code.should == 500
      @response.content_type.should == "application/json"
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

    it "should render a template with excess controller variables" do
      test_action(:render_template_with_excess_variables).should == "Default foobar"
    end

    it "should raise if rendering a #needs template with excess controller variables" do
      proc { test_action(:render_needs_template_with_excess_variables) }.should raise_error(ActionView::TemplateError, /Excess parameters?.*: .*barfoo/)
    end

    it "should render a #needs template with excess controller variables and ignore_extra_controller_assigns" do
      test_action(:render_needs_template_with_excess_variables_and_ignoring_extras).should == "Needs foobar"
    end

    it "should respect ignore_extra_controller_assigns in subclasses" do
      test_action(:render_needs_subclass_template_with_excess_variables_and_ignoring_extras).should == "NeedsSubclass foobar"
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

    it "should render an ERB template which uses an erector widget partial with locals" do
      test_action(:render_erector_with_locals_from_erb).should == "Partial, foo hihi, bar byebye"
    end

    it "should render an ERB template which uses an erector widget partial with helpers" do
      test_action(:render_erector_with_helpers_from_erb).should match '<form'
    end

    it "should render an ERB template which uses an erector widget partial with a defaulted local" do
      test_action(:render_erector_with_locals_from_erb_defaulted).should == "Partial, foo hihi, bar 12345"
    end

    it "should override instance variables with local variables when rendering partials" do
      test_action(:render_erector_with_locals_from_erb_override).should == "Partial, foo localfoo, bar 12345"
    end

    it "should raise if passing a local that's not needed" do
      proc { test_action(:render_erector_with_locals_from_erb_not_needed) }.should raise_error(ActionView::TemplateError, /Excess parameters?.*: .*baz/)
    end

    it "should not pass unneeded controller variables to a partial" do
      test_action(:render_erector_partial_with_unneeded_controller_variables).should == "Partial, foo localfoo, bar 12345"
    end

    it "should not pass controller variables to a partial at all, if requested" do
      test_action(:render_erector_partial_without_controller_variables).should == "Partial, foo localfoo, bar 12345"
    end

    it "should render a default template" do
      test_action(:render_default).should == "Default foobar"
    end

    it "should render a default erb template with default erb layout" do
      TestController.layout 'erb_as_layout'
      test_action(:render_default_erb_with_layout).should == "layout content\nerb content"
    end

    it "should render a default widget with default erb layout" do
      TestController.layout 'erb_as_layout'
      test_action(:render_default_widget_with_layout).should == "layout content\nwidget content"
    end

    it "should render a default erb template with default widget layout" do
      TestController.layout 'widget_as_layout'
      test_action(:render_default_erb_with_layout).should == "BEFOREerb contentAFTER"
    end

    it "should render a default widget with default widget layout" do
      TestController.layout 'widget_as_layout'
      test_action(:render_default_widget_with_layout).should == "BEFOREwidget contentAFTER"
    end

    it "should allow rendering widget with needs" do
      proc { test_action(:render_with_needs) }.should_not raise_error
    end

    it "should allow using a widget as a layout" do
      test_action(:render_with_widget_as_layout).should == "BEFOREDURINGAFTER"
    end

    it "should allow using a widget as a layout with instance vars" do
      test_action(:render_with_widget_as_layout_and_vars).should == "BreakfastLunchDinner"
    end

    it "should allow using a widget as a layout using content_for" do
      test_action(:render_with_widget_as_layout_using_content_for).should == "TOPBEFOREDURINGAFTER"
    end

    it "allows for the same needs name as partial name" do
      test_action(:render_with_needs_name_same_as_partial_name).should == "FooBar"
    end

    it "passes the correct virtual path" do
      test_action(:render_virtual_path).should == "test/render_virtual_path.rb,test/_virtual_path_partial.rb"
    end

  end
end
