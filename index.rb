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
    
    h2.clear "Examples"
    
    example <<-RUBY, <<-HTML
require 'erector'

class Hello < Erector::Widget
  def content
    html {
      head {
        title "Hello"
      }
      body {
        h1.heading! "Message:"
        text "Hello, "
        b.big @target
        text "!"
      }
    }
  end
end

Hello.new(:target => 'world').to_html
    RUBY
<html>
  <head>
    <title>Hello</title>
  </head>
  <body>
    <h1 id="heading">Message:</h1>
    Hello, <b class="big">world</b>!
  </body>
</html>
    HTML
    
    example <<-RUBY, <<-HTML
include Erector::Mixin
erector { div "love", :class => "big" }
    RUBY
<div class="big">love</div>
    HTML

    example <<-RUBY, <<-HTML
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
    RUBY
<div class="logo">
  <a href="index.html">
    <img class="logo" height="323" 
      src="erector.jpg" width="287" />
  </a>
</div>
    HTML
    
    hr
    p "Current version: #{Erector::VERSION}"

  end
  
end

