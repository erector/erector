dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/navbar"

require "rubygems"
require "bundler"
Bundler.setup
require 'rdoc/markup'
require 'rdoc/markup/to_html'

class Index < Page
  def initialize
    super(:page_title => "Home")
  end
  
  def body_content
    p {
      text "Erector is a Builder-like view framework for ", a("Ruby", :href=>"http://ruby-lang.org")
      text ", inspired by "
      a "Markaby", :href => "http://code.whytheluckystiff.net/markaby/"
      text ". "
    }
    
    p {
      text "In Erector all views are objects, not template files, which allows the full power of object-oriented programming (inheritance, modular decomposition, encapsulation) in views."
    }
    
    source :ruby, <<-RUBY
require 'erector'
class Logo < Erector::Widget
  def content
    div.logo {
      a(:href => "index.html") {
        img.logo :src => 'erector.jpg',
          :height => 323, 
          :width => 287
      }
    }
  end
end

Logo.new.to_html #=>
  RUBY
    source :html, <<-HTML
<div class="logo">
  <a href="index.html">
    <img class="logo" height="323" src="erector.jpg" width="287" />
  </a>
</div>
    HTML

    p do
      text "Don't forget to read the "
      a "User Guide", :href => "userguide.html"
      text " and "
      a "FAQ", :href => "faq.html"
      text " and "
      a "API", :href => "rdoc"
      text " documentation!"
    end
  end
end

