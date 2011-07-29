dir = File.dirname(__FILE__)
require "#{dir}/sidebar"
require "#{dir}/clickable_li"

# todo: inherit from Erector::Widgets::Page

class Page < Erector::Widget
  needs :page_title => nil, :selection => nil

  def real_page_title
    @page_title || self.class.name
  end
  
  def selection
    @selection || @page_title.downcase
  end
  
  def clickable_li(item, href)
    widget ClickableLi, :item => item, :href => href
  end
  
  def content
    html do
      head do
        title "Erector - #{real_page_title}"
        css "erector.css"
      end
      body do
        
        widget Sidebar.new(:current_page => selection)

        div.main do

          h1.title do
            img :src => 'erector-logo.png'
            br
            text real_page_title
          end

          div.body do
            render_body
          end
        end
        
        div.footer do
          center do
            text "Erector is an open source project released under the MIT license. Its initial development was sponsored by "
            a "Pivotal Labs", :href => "http://pivotallabs.com"
            text "."
            br
            center do
              a :href => "http://www.pivotallabs.com" do
                img :src => "pivotal.gif", :width => 158, :height => 57, :alt => "Pivotal Labs"
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
