here = File.dirname(__FILE__)
require "#{here}/navbar"
require "#{here}/logo"
require "#{here}/clickable_li"
require "#{here}/promo"
require "#{here}/source"
require "#{here}/example"
require "#{here}/fork_me"

# todo: inherit from Erector::Widgets::Page

class Page < Erector::Widget
  needs :page_title
  include Source
  include Example
  
  def display_name
    @page_title || self.class.name
  end
  
  ##
  # Convert to snake case.
  #
  #   "FooBar".snake_case           #=> "foo_bar"
  #   "HeadlineCNNNews".snake_case  #=> "headline_cnn_news"
  #   "CNN".snake_case              #=> "cnn"
  #
  # @return [String] Receiver converted to snake case.
  #
  # @api public
  # borrowed from https://github.com/datamapper/extlib/blob/master/lib/extlib/string.rb
  def snake_case(s)
    if s.match(/\A[A-Z]+\z/)
      s.downcase
    else
      s.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
       gsub(/([a-z])([A-Z])/, '\1_\2').
       downcase
    end
  end

  def name
    snake_case(self.class.name)
  end
  
  def href
     name + ".html"
  end
  
  def clickable_li(item, href)
    widget ClickableLi, :item => item, :href => href
  end
  
  def content
    html do
      head do
        title "Erector - #{display_name}"
        here = File.dirname(__FILE__)
        scss "#{here}/erector.scss"
        
        script :src=>"js/sh_main.min.js"
        script :src=>"js/sh_lang/sh_ruby.min.js"
        script :src=>"js/sh_lang/sh_html.min.js"
        script :src=>"js/sh_lang/sh_sh.min.js"
        css "css/sh_style.css"        
      end
      body :onload => "sh_highlightDocument();" do
        widget ForkMe
        div.top do
          div.logo do
            a(:href => "index.html") { img :src => 'erector-logo.png' }
          end
        end
        widget Navbar.new(:current_page => self)
        widget Promo, :src => promo
        
        div.main do
          div.body do
            body_content
          end          
          footer
        end
      end
    end
  end
  
  def promo
    "images/erector-the-worlds-greatest-toy.jpg"
  end

  def footer
    div.footer do
      a :href => "http://www.pivotallabs.com" do
        img :src => "pivotal.gif", :width => 158, :height => 57, :alt => "Pivotal Labs", :style => "float:right; padding: 8px;"
      end
      center do
        text "Erector is an open source project released under the MIT license."
        br
        text "Its initial development was sponsored by ", a("Pivotal Labs", :href => "http://pivotallabs.com"), "."
        br
        text "Not affiliated with or sponsored by the makers of Erector or Meccano toys."
      end
    end
  end
  
  # override me
  def body_content
    raise "override me"
  end
end
