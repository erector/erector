class Views::Test::RenderPartial < Erector::RailsWidget
  def content
    rawtext helpers.render(:partial => 'erector')
  end
end
