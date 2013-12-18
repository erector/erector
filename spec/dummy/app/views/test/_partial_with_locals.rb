class Views::Test::PartialWithLocals < Erector::Widget
  needs :foo, :bar => 12345
  
  def content
    text "Partial, foo #{@foo}, bar #{@bar}"
  end
end
