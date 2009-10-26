class Views::Test::Erector < Erector::RailsWidget
  def render_partial
    text "Partial #{@foobar}"
  end
end
