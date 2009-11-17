class Views::Test::Needs < Erector::Widget
  needs :foobar
  
  def content
    text "Needs #{@foobar}"
  end
end
