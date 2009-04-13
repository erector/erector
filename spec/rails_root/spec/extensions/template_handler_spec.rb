require File.expand_path("#{File.dirname(__FILE__)}/../rails_spec_helper")
require "action_controller/test_process"

module TemplateHandlerSpecs
  
  class TemplateHandlerSpecsController < ActionController::Base
    def index
      @foo = "foo"
      render :template => "template_handler_specs/test_page.html.rb"
    end

    def action_with_instance_variables_being_passed_into_render_call
      require "#{RAILS_ROOT}/app/views/template_handler_specs/action_with_instance_variables_being_passed_into_render_call.html"
      render :widget => Views::TemplateHandlerSpecs::ActionWithInstanceVariablesBeingPassedIntoRenderCall, :foo => "foo"
    end
  end
  
  describe ActionView::TemplateHandlers::Erector do
    attr_reader :request, :controller
    before do
      @request = ActionController::TestRequest.new({:action => "index"})
      @controller = TemplateHandlerSpecsController.new
    end

    it "assigns instance variables, renders partials, and properly handles controllers with pluralized names" do
      request.action = "index"
      response = ActionController::TestResponse.new
      controller.process(request, response)
      view = response.template
      
      response.body.strip.gsub("  ", "").gsub("\n", "").should == '<div class="page"><div class="partial">foo</div></div>'
    end

    it "accepts instance variables being passed into render" do
      request.action = "action_with_instance_variables_being_passed_into_render_call"
      response = ActionController::TestResponse.new
      controller.process(request, response)
      view = response.template

      response.body.strip.gsub("  ", "").gsub("\n", "").should == '<div class="page">Value of @foo is </div>'
    end
  end

end
