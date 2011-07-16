class Views::Test::NeedsSubclass < Views::Test::Needs
  def content
    text "NeedsSubclass #{@foobar}"
  end
end
