class Page < Erector::Widget
  needs :page_title => nil, :selection => nil
  
  def real_page_title
    @page_title || self.class.name
  end
  
  def selection
    @selection || page_title.downcase
  end
  
  def content
    html do
      head do
        title "Erector - #{real_page_title}"
        css "erector.css"
      end
      body do
        table do
          tr do
            td "valign" => "top" do
              widget Sidebar.new(:current_page => selection)
            end
            td "valign" => "top" do
              h1 :class => "title" do
                text "Erector - #{real_page_title}"
              end

              hr

              div :class => "body" do
                render_body
              end
            end
          end
          tr do
            td :colspan=>2 do
              hr
              center do
                text "Erector is an open source project released under the MIT license. Its initial development was sponsored by "
                a "Pivotal Labs", :href => "http://pivotallabs.com"
                text "."
              end
            end
          end
        end
      end
    end
  end
  
  # override me
  def render_body
  end
end
