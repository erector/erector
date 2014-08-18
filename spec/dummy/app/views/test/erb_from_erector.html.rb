class Views::Test::ErbFromErector < Erector::Widget
  def content
    rawtext parent.render(:partial => 'erb')
  end
end
