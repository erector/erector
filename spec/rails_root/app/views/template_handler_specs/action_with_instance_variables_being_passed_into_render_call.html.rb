class Views::TemplateHandlerSpecs::ActionWithInstanceVariablesBeingPassedIntoRenderCall < Erector::RailsWidget
  def write
    div "Value of @foo is #{@foo}", :class => 'page'
  end
end
