class Views::TemplateHandlerSpecs::TestPage < Erector::RailsWidget
  def render_partial
    div :class => 'partial' do
      text @foo
    end
  end
end
