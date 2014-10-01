class Views::Test::VirtualPathPartial < Erector::Widget
  def content
    text @virtual_path
  end
end
