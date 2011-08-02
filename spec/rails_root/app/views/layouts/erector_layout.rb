class Views::Layouts::ErectorLayout < Erector::Widget
  needs :layout_need => 'erector'
  
  def content
    rawtext content_for(:layout)
    text "with #{@layout_need} layout"
  end
end
