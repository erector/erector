class Page < Erector::Widget
  def initialize(title = self.class.name, selection = title.downcase)
    super
    @title = title
    @selection = selection
  end
  
  def render
    html do
      head do
        title "Erector - #{@title}"
        css "erector.css"
      end
      body do
        table do
          tr do
            td "valign" => "top" do
              Sidebar.new(@selection).render_to(doc)
            end
            td "valign" => "top" do
              h1 :class => "title" do
                text "Erector - #{@title}"
              end

              hr

              div :class => "body" do
                render_body
              end
            end
          end
        end
      end
    end
  end
  
  def render_body
  end
end
