class Views::TemplateHandlerSpec::TestPartial < Erector::Widget
  def render
    div :class => 'partial' do
      text @foo
    end
  end
end
