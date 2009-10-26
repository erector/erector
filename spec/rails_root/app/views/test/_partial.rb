class Views::Test::Partial < Erector::RailsWidget
  def render_partial
    text "Partial #{@foobar}"
  end
end
