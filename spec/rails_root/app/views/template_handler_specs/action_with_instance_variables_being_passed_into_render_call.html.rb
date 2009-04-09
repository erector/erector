class Views::TemplateHandlerSpecs::ActionWithInstanceVariablesBeingPassedIntoRenderCall < Erector::RailsWidget
  def render
    div "Value of @foo is #{@foo}", :class => 'page'
  end
end
