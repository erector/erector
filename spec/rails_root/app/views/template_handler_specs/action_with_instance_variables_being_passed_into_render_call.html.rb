class Views::TemplateHandlerSpecs::ActionWithInstanceVariablesBeingPassedIntoRenderCall < Erector::Widget
  def render
    div "Value of @foo is #{@foo}", :class => 'page'
  end
end
