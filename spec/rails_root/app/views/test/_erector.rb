class Views::Test::Erector < Erector::Widget
  def render_partial
    text "Partial #{@foobar}"
  end
end
