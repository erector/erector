class Views::Test::ErbFromErector < Erector::Widget
  def content
    text! parent.render(:partial => 'erb')
  end
end
