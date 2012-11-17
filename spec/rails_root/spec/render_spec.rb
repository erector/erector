require File.expand_path("#{File.dirname(__FILE__)}/rails_spec_helper")
require File.expand_path("#{File.dirname(__FILE__)}/test_widgets")
require File.expand_path("#{File.dirname(__FILE__)}/controller_spec_helper")
# We need this, because we reference Views::Test::Needs below, and it
# doesn't auto-load otherwise.
require 'views/test/needs.html.rb'

include(ControllerSpecHelper)

shared_examples_for "expected of render: " do

  it "should render a template with implicit assigns" do
    test_controller.with_action do
      @foobar = "foobar"
      render :template => "test/implicit_assigns", :handlers => [:rb]
    end
    test_action.should == "foobar"
  end

  it "should not include protected instance variables in assigns" do
    test_controller.with_action do
      render :template => "test/protected_instance_variable", :handlers => [:rb]
    end
    test_action.should == ""
  end

  it "should render a template without a .html format included" do
    test_controller.with_action do
      render :template => "test/bare", :handlers => [:rb], :bare => true
    end
    test_action.should == "Bare"
  end

  it "should render a template with excess controller variables" do
    test_controller.with_action do
      with_ignoring_extra_controller_assigns(Views::Test::Needs, false) do
        @foobar = "foobar"
        @barfoo = "barfoo"
        render :template => 'test/render_default', :handlers => [:rb]
      end
    end
    test_action.should == "Default foobar"
  end

  it "should raise if rendering a #needs template with excess controller variables" do
    test_controller.with_action do
      with_ignoring_extra_controller_assigns(Views::Test::Needs, false) do
        @foobar = "foobar"
        @barfoo = "barfoo"
        render :template => 'test/needs', :handlers => [:rb]
      end
    end
    proc { test_action }.should raise_error(ActionView::TemplateError, /Excess parameters?.*: .*barfoo/)
  end

  it "should render a #needs template with excess controller variables and ignore_extra_controller_assigns" do
    test_controller.with_action do
      @foobar = "foobar"
      @barfoo = "barfoo"
      render :template => 'test/needs', :handlers => [:rb]
    end
    test_action.should == "Needs foobar"
  end

  it "should respect ignore_extra_controller_assigns in subclasses" do
    test_controller.with_action do
      @foobar = "foobar"
      @barfoo = "barfoo"
      render :template => 'test/needs_subclass', :handlers => [:rb]
    end
    test_action.should == "NeedsSubclass foobar"
  end

  it "should render a template which uses partials" do
    test_controller.with_action do
      @foobar = "foobar"
      render :template => "test/render_partial", :handlers => [:rb]
    end
    test_action.should == "Partial foobar"
  end

  it "should render an erector widget which uses an ERB partial'" do
    test_controller.with_action do
      @foobar = "foobar"
      render :template => "test/erb_from_erector", :handlers => [:rb]
    end
    test_action.should == "Partial foobar"
  end

  it "should render an ERB template which uses an erector widget partial" do
    test_controller.with_action do
      @foobar = "foobar"
      render :template => "test/erector_from_erb", :handlers => [:erb]
    end
    test_action.should == "Partial foobar"
  end

  it "should render an ERB template which uses an erector widget partial with locals" do
    test_controller.with_action do
      @local_foo = "hihi"
      @local_bar = "byebye"
      render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
    end
    test_action.should == "Partial, foo hihi, bar byebye"
  end

  it "should render an ERB template which uses an erector widget partial with a defaulted local" do
    test_controller.with_action do
      @local_foo = "hihi"
      render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
    end
    test_action.should == "Partial, foo hihi, bar 12345"
  end

  it "should override instance variables with local variables when rendering partials" do
    test_controller.with_action do
      @foo       = "globalfoo"
      @local_foo = "localfoo"
      render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
    end
    test_action.should == "Partial, foo localfoo, bar 12345"
  end

  it "should raise if passing a local that's not needed" do
    test_controller.with_action do
      @local_foo = "localfoo"
      @local_baz = "unneeded"
      render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
    end
    proc { test_action }.should raise_error(ActionView::TemplateError, /Excess parameters?.*: .*baz/)
  end

  it "should not pass unneeded controller variables to a partial" do
    test_controller.with_action do
      @local_foo = "localfoo"
      @baz       = "unneeded"
      render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
    end
    test_action.should == "Partial, foo localfoo, bar 12345"
  end

  it "should not pass controller variables to a partial at all, if requested" do
    test_controller.with_action do
      with_controller_assigns_propagate_to_partials(Views::Test::PartialWithLocals, false) do
        @local_foo = "localfoo"
        @bar       = "barbar"
        render :template => 'test/erector_with_locals_from_erb', :handlers => [:erb]
      end
    end
    test_action.should == "Partial, foo localfoo, bar 12345"
  end

  it "should render a default template" do
    test_controller.with_action(:render_default) do
      @foobar = "foobar"
    end
    test_action(:render_default).should == "Default foobar"
  end

  it "should render a default erb template with default erb layout" do
    test_controller.with_action(:render_default_erb_with_layout) do
      @erb_content    = "erb content"
      @layout_content = "layout content"
    end
    with_layout(TestController, 'erb_as_layout') do
      test_action(:render_default_erb_with_layout).should == "layout content\nerb content"
    end
  end

  it "should render a default widget with default erb layout" do
    test_controller.with_action(:render_default_widget_with_layout) do
      @widget_content = "widget content"
      @layout_content = "layout content"
    end
    with_layout(TestController, 'erb_as_layout') do
      test_action(:render_default_widget_with_layout).should == "layout content\nwidget content"
    end
  end

  it "should render a default erb template with default widget layout" do
    test_controller.with_action(:render_default_erb_with_layout) do
      @erb_content    = "erb content"
      @layout_content = "layout content"
    end
    with_layout(TestController, 'widget_as_layout') do
      test_action(:render_default_erb_with_layout).should == "BEFOREerb contentAFTER"
    end
  end

  it "should render a default widget with default widget layout" do
    test_controller.with_action(:render_default_widget_with_layout) do
      @widget_content = "widget content"
      @layout_content = "layout content"
    end
    with_layout(TestController, 'widget_as_layout') do
      test_action(:render_default_widget_with_layout).should == "BEFOREwidget contentAFTER"
    end
  end

  it "should allow using a widget as a layout" do
    test_controller.with_action(:render_with_widget_as_layout) do
      render :layout => "layouts/widget_as_layout"
    end
    test_action(:render_with_widget_as_layout).should == "BEFOREDURINGAFTER"
  end

  it "should allow using a widget as a layout with instance vars" do
    test_controller.with_action do
      @before = "Breakfast"
      @during = "Lunch"
      @after  = "Dinner"
      render :template => "test/render_with_widget_as_layout", :layout => "layouts/widget_as_layout"
    end
    test_action.should == "BreakfastLunchDinner"
  end

  it "should allow using a widget as a layout using content_for" do
    test_controller.with_action do
      render :template => "test/render_with_widget_as_layout_using_content_for", :layout => "layouts/widget_as_layout"
    end
    with_layout(TestController, 'widget_as_layout') do
      test_action.should == "TOPBEFOREDURINGAFTER"
    end
  end

end

describe ActionController::Base do

  def test_action!(action)
    @response = TestController.action(action).call(Rack::MockRequest.env_for("/path"))[2]
    @response.body
  end

  describe "#render" do

    context "via widget" do

      def test_action(action = 'default')
        test_action!(action)
      end

      it "should render a widget class with implicit assigns" do
        test_controller.with_action do
          @foobar = "foobar"
          render :widget => TestWidget
        end
        test_action.should == "foobar"
      end

      it "should render a widget instance with explicit assigns" do
        test_controller.with_action do
          render :widget => TestWidget.new(:foobar => "foobar")
        end
        test_action.should == "foobar"
      end


      it "should allow rendering widget with needs" do
        test_controller.with_action do
          @foo = "foo"
          @bar = "bar"
          render :widget => NeedsWidget
        end
        proc { test_action }.should_not raise_error
      end


      it "should render a widget class with implicit assigns and ignoring extra variables" do
        test_controller.with_action do
          @foo = "foo"
          @baz = "baz"
          render :widget => NeedsWidget
        end
        test_action.should == "foo foo bar true"
      end

      it "should raise when rendering a widget class with implicit assigns and too many variables" do
        test_controller.with_action do
          with_ignoring_extra_controller_assigns(NeedsWidget, false) do
            @foo = "foo"
            @baz = "baz"
            render :widget => NeedsWidget
          end
        end
        proc { test_action }.should raise_error(ArgumentError, /Excess parameters?.*: .*baz/)
      end

      it "should render a specific content method" do
        test_controller.with_action do
          render :widget => TestWidget, :content_method_name => :content_method
        end
        test_action.should == "content_method"
      end

      it "should pass rails options to base render method" do
        test_controller.with_action do
          render :widget => TestWidget, :status => 500, :content_type => "application/json"
        end
        test_action
        @response.response_code.should == 500
        @response.content_type.should == "application/json"
      end
    end

    context "via template" do

      context "with default view path settings" do

        def test_action(action = 'default')
          test_action!(action)
        end

        it_behaves_like "expected of render: "
      end

      context "with custom view path" do

        context "with correct global default widget class prefix" do

          def test_action(action = 'default')
            with_view_paths(TestController, Rails.root.join('lib/custom_views')) do
              with_defaults(:widget_class_prefix => :views) do
                test_action!(action)
              end
            end
          end

          it_behaves_like "expected of render: "

        end

        context "with incorrect global default widget class prefix" do

          def test_action(action = 'default')
            with_view_paths(TestController, Rails.root.join('lib/custom_views')) do
              with_defaults(:widget_class_prefix => :custom_views) do
                test_action!(action)
              end
            end
          end

          it "should raise error on undefined widget class" do
            test_controller.with_action(:render_default)
            proc { test_action(:render_default) }.should raise_error(ActionView::TemplateError, /expected to define widget class CustomViews::Test/)
          end

          it "should raise error on missing template" do
            test_controller.with_action(:render_missing_default_template)
            proc { test_action(:render_missing_default_template) }.should raise_error(ActionView::MissingTemplate)
          end

          it "should raise error on missing template" do
            test_controller.with_action(:fallback_default_template)
            proc { test_action(:fallback_default_template) }.should raise_error(ActionView::MissingTemplate)
          end

        end
      end

      context "with custom widget library resolver on view path" do

        context "with explicit widget class prefix irrespective of global widget class prefix" do

          WIDGET_RESOLVER =
              Erector::Rails::WidgetLibraryResolver.new(:views,
                                                        Rails.root.join('lib/custom_views'))

          def test_action(action = 'default')
            with_view_paths(TestController, WIDGET_RESOLVER) do
              with_defaults(:widget_class_prefix => :default_views) do
                test_action!(action)
              end
            end
          end

          it_behaves_like "expected of render: "

        end

        context "with implicit widget class prefix and global widget class prefix correctly set" do

          IMPLICIT_WIDGET_RESOLVER = Erector::Rails::WidgetLibraryResolver.new(nil,
                                                                      Rails.root.join('lib/custom_views'))

          def test_action(action = 'default')
            with_view_paths(TestController, IMPLICIT_WIDGET_RESOLVER) do
              with_defaults(:widget_class_prefix => :views) do
                test_action!(action)
              end
            end
          end

          it_behaves_like "expected of render: "

        end

      end

      context "with custom action widget library fallback resolver on view path" do

        module ::ActionWidgets
          module Test
          end
          module WrongClass
          end
        end

        ACTION_WIDGET_RESOLVER =
            Erector::Rails::ActionWidgetLibraryResolver.new(:action_widgets,
                                                            Rails.root.join('lib/action_widgets'))

        def test_action(action = 'default')
          with_view_paths(TestController, [Rails.root.join('app/views'), ACTION_WIDGET_RESOLVER]) do
            with_defaults(:widget_class_prefix => :views) do
              test_action!(action)
            end
          end
        end

        context "with templates found on app/views path" do

          it_behaves_like "expected of render: "

        end

        context "when template fallback to action widget library" do

          it "should raise error if incorrect widget class" do
            test_controller.with_action(:fallback_action_widget_with_wrong_class)
            proc { test_action(:fallback_action_widget_with_wrong_class) }.should raise_error(ActionView::TemplateError, /expected to define widget class ActionWidgets::FallbackActionWidgetWithWrongClass/)
          end

          it "should raise error on missing template" do
            test_controller.with_action(:fallback_missing_action_widget)
            proc { test_action(:fallback_missing_action_widget) }.should raise_error(ActionView::MissingTemplate)
          end

          it "should render fallback action widget if template missing on default view path" do
            test_controller.with_action(:fallback_action_widget)
            test_action(:fallback_action_widget).should == 'action widget content '
          end

          it "should render fallback action widget if template missing on default view path with default layout" do
            test_controller.with_action(:fallback_action_widget)
            with_layout(TestController, 'widget_as_layout') do
              test_action(:fallback_action_widget).should == "BEFOREaction widget content AFTER"
            end
          end

          it "should render fallback action widget if template missing on default view path even if given with prefix" do
            test_controller.with_action do
              render :template => 'test/fallback_action_widget'
            end
            test_action.should == 'action widget content '
          end

          it "should not fallback to action widget if template not missing on default view path" do
            test_controller.with_action(:render_default)
            test_action(:render_default).should == "Default "
            test_action(:render_default).should_not == "action widget default "
          end


        end

      end

    end

  end

end
