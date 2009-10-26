class Views::Test::RenderDefault < Erector::RailsWidget
  def content
    text "Default #{@foobar}"
  end
end
