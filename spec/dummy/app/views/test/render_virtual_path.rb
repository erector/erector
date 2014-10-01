class Views::Test::RenderVirtualPath < Erector::Widget
  def content
    text @virtual_path
    text ','
    render 'virtual_path_partial'
  end
end
