class Views::Test::ProtectedInstanceVariable < Erector::Widget
  def content
    text @_response
  end
end
