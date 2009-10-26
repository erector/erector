class Views::Test::ProtectedInstanceVariable < Erector::RailsWidget
  def content
    text @_response
  end
end
