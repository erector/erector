class Views::Test::ErbFromErector < Erector::RailsWidget
  def content
    rawtext helpers.render :partial => 'erb'
  end
end
