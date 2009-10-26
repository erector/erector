class Views::Test::Partial < Erector::RailsWidget
  def render_partial
    text @foobar
  end
end
