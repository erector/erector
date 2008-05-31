require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module BaseSpec
  class TestWidgetController < ActionController::Base
    def index_with_implicit_assigns
      @foobar = "foobar"
      render_widget TestWidget
    end

    def index_with_explicit_assigns
      render_widget TestWidget, :foobar => "foobar"
    end

    def index_with_render_colon_widget
      render :widget => TestWidget, :foobar => "foobar"
    end
  end

  class TestWidget < Erector::Widget
    def render
      text @foobar
    end
  end

  describe TestWidgetController do
    context "rendering widgets" do
      before do
        @controller = BaseSpec::TestWidgetController.new
        @request = ActionController::TestRequest.new
        @response = ActionController::TestResponse.new
        @controller.send(:initialize_template_class, @response)
        @controller.send(:assign_shortcuts, @request, @response)
        class << @controller
          public :rendered_widget, :render
        end
      end

      describe "#render_widget" do
        it "assigns to @rendered_widget" do
          @controller.rendered_widget.should be_nil
          @controller.render_widget TestWidget
          @controller.rendered_widget.should be_instance_of(TestWidget)
        end

        it "instantiates a widget with implicit assigns" do
          @controller.index_with_implicit_assigns
          @response.body.should == "foobar"
        end

        it "instantiates a widget with explicit assigns" do
          @controller.index_with_explicit_assigns
          @response.body.should == "foobar"
        end
      end

      describe "#render :widget" do
        it "assigns to @rendered_widget" do
          @controller.rendered_widget.should be_nil
          @controller.render :widget => TestWidget
          @controller.rendered_widget.should be_instance_of(TestWidget)
        end

        it "instantiates a widget with implicit assigns" do
          @controller.index_with_implicit_assigns
          @response.body.should == "foobar"
        end

        describe "#render :widget" do
          it "assigns to @rendered_widget" do
            @controller.rendered_widget.should be_nil
            @controller.render :widget => TestWidget
            @controller.rendered_widget.should be_instance_of(TestWidget)
          end

          it "instantiates a widget with explicit assigns" do
            @controller.index_with_render_colon_widget
            @response.body.should == "foobar"
          end
        end
      end
    end
  end
end