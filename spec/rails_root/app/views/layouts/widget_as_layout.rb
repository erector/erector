class Views::Layouts::WidgetAsLayout < Erector::Widget
  def content
    text content_for(:top) if content_for?(:top)
    text @before || "BEFORE"
    rawtext content_for(:layout)
    text @after || "AFTER"
  end
end
