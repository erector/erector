class Views::Test::RenderPartial < Erector::Widget
  def content
    rawtext parent.render(:partial => 'erector')
  end
end
