class Views::TemplateHandlerSpec::TestPage < Erector::Widget
  def render
    div :class => 'page' do
      rawtext helpers.render(
        :partial => 'template_handler_spec/test_page',
        :locals => {:foo => @foo}
      )
    end
  end
end
