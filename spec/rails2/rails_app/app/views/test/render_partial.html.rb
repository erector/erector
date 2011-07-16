class Views::Test::RenderPartial < Erector::Widget
  def content
    text! parent.render(:partial => 'erector')
  end
end
