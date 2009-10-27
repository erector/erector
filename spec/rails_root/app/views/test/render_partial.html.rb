class Views::Test::RenderPartial < Erector::Widget
  def content
    rawtext helpers.render(:partial => 'erector')
  end
end
