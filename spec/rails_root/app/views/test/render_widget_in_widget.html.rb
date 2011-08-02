class Views::Test::RenderWidgetInWidget < Erector::Widget
  def content
    render :widget => TestWidget
  end
end
