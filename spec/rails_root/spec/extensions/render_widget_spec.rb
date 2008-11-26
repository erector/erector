require File.expand_path("#{File.dirname(__FILE__)}/../rails_spec_helper")

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
      @foobar = "foobar"
      render :widget => TestWidget
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
        @response = ActionController::TestResponse.new
        class << @controller
          public :render
        end
      end

      describe "#render_widget" do
        it "instantiates a widget with implicit assigns" do
          @request = ActionController::TestRequest.new({:action => "index_with_implicit_assigns"})
          @controller.process(@request, @response)
          @response.body.should == "foobar"
        end

        it "instantiates a widget with explicit assigns" do
          @request = ActionController::TestRequest.new({:action => "index_with_explicit_assigns"})
          @controller.process(@request, @response)
          @response.body.should == "foobar"
        end
      end

      describe "#render :widget" do
        it "instantiates a widget with implicit assigns" do
          @request = ActionController::TestRequest.new({:action => "index_with_implicit_assigns"})
          @controller.process(@request, @response)
          @response.body.should == "foobar"
        end

        describe "#render :widget" do
          it "instantiates a widget with explicit assigns" do
            @request = ActionController::TestRequest.new(:action => "index_with_render_colon_widget")
            @controller.process(@request, @response)
            @response.body.should == "foobar"
          end
        end
      end
    end
  end
end