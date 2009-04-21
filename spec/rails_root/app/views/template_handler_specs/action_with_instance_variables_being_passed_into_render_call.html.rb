class Views::TemplateHandlerSpecs::ActionWithInstanceVariablesBeingPassedIntoRenderCall < Erector::RailsWidget
  def content
    div "Value of @foo is #{@foo}", :class => 'page'
  end
end
