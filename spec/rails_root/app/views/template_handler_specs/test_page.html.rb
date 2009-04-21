class Views::TemplateHandlerSpecs::TestPage < Erector::RailsWidget
  def write
    div :class => 'page' do
      rawtext(helpers.render(:partial => 'template_handler_specs/test_page', :locals => {:foo => @foo}))
    end
  end
end
