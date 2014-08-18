class Views::Test::Users < Erector::Widget

  def content
    ["Foo", "Bar"].each do |x|
      render 'user', user: x
    end
  end

end
