class Views::Test::Erector < Erector::Widget
  def content
    text "Partial #{@foobar}"
  end
end
