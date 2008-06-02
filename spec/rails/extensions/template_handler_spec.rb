require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

ActionView::Base.class_eval do
  def render_partial_with_notification
    @is_partial_template = true
    render_partial_without_notification
  end
  alias_method_chain :render_partial, :notification

  def is_partial_template?
    @is_partial_template || false
  end
end

module TemplateHandlerSpec
  
  class TemplateHandlerSpecController < ActionController::Base
  end
  
  describe ActionView::TemplateHandlers::Erector do
    attr_reader :controller, :view, :request, :response
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
      @view = @response.template
    end

    it "assigns locals" do
#      handler = ActionView::TemplateHandlers::Erector.new(view)
#      content = File.read("#{RAILS_ROOT}/app/views/template_handler_spec/test_page.rb")
#      mock.proxy(handler).render(content, {:foo => "bar"})

      controller.render :template => "template_handler_spec/test_page"
#      response.body.should == "<div class=\"partial\">bar</div>"
    end
  end

end
