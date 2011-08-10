class Views::Test::RenderWithWidgetAsLayout < Erector::Widget
  def content
    text @during || "DURING"
  end
end
