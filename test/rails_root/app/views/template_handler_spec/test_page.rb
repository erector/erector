class Views::TemplateHandlerSpec::TestPage < Erector::Widget
  def render
    div :class => 'page' do
      p @foo
      helpers.render :partial => 'test_partial', :locals => {:foo => @foo}
    end
  end
end
