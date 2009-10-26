class Views::Test::RenderPartial < Erector::RailsWidget
  def content
    rawtext helpers.render(:partial => 'partial', :locals => {:foobar => @foobar})
  end
end
