class Views::Test::ErbFromErector < Erector::Widget
  def content
    rawtext helpers.render :partial => 'erb'
  end
end
