require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module TemplateHandlerSpec
  
  class TemplateHandlerSpecController < ActionController::Base
  end
  
  describe ActionView::TemplateHandlers::Erector do

    before do
      @controller = TemplateHandlerSpecController.new
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new
      @controller.send(:initialize_template_class, @response)
      @controller.send(:assign_shortcuts, @request, @response)
      class << @controller
        public :rendered_widget, :render
      end
      @controller.append_view_path("#{RAILS_ROOT}/app/views")
    end

    it "assigns locals" do
      handler = ActionView::TemplateHandlers::Erector.new(@controller)
      handler.render("class Views::TemplateHandlerSpec::TestPartial", {:foo => "bar"}).should == 
        "<div class=\"partial\">bar</div>"
    end
  end

end
