class Views::Test::RenderDefaultWidgetWithLayout < Erector::Widget
  def content
    text "#{@widget_content}"
  end
end
