require File.expand_path("#{File.dirname(__FILE__)}/../rails_spec_helper")
require "action_controller/test_process"

module TemplateHandlerSpec
  
  class TemplateHandlerSpecController < ActionController::Base
    def index
      @foo = "foo"
      render :template => "template_handler_spec/test_page"
    end
  end
  
  describe ActionView::TemplateHandlers::Erector do
    attr_reader :controller, :view, :request, :response
    before do
      @controller = TemplateHandlerSpecController.new

      @request = ActionController::TestRequest.new({:action => "index"})
      @response = ActionController::TestResponse.new
      @controller.process(@request, @response)
      class << @controller
        public :render
      end
      @view = @response.template
    end

    it "assigns locals" do
      response.body.strip.gsub!("  ", "").gsub!("\n", "").should == '<div class="page"><div class="partial">foo</div></div>'
    end
  end

end
