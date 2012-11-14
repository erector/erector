class Views::Layouts::WidgetAsLayout < Erector::Widget
  def content
    content_for(:top) if content_for?(:top)
    text @before || "BEFORE"
    content_for(:layout)
    text @after || "AFTER"
  end
end
