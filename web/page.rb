class Page < Erector::Widget
  def render
    html do
      head do
        title @title
      end
      body do
        render_body
      end
    end
  end
  
  def render_body
  end
end
