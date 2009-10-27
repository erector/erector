class Views::Test::RenderDefault < Erector::Widget
  def content
    text "Default #{@foobar}"
  end
end
