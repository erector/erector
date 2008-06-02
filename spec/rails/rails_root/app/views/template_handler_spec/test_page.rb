class Views::TemplateHandlerSpec::TestPage < Erector::Widget
  def render
    div :class => 'page' do
      helpers.render :partial => 'template_handler_spec/test_partial', :locals => {:foo => @foo}
    end
  end
end
