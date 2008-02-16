$: << "../lib"
require 'erector'

class Page < Erector::Widget
  attr_accessor :content
  attr_accessor :head_elements
  
  def initialize
    super
    @head_elements = []
  end

  def render
    instruct!
    html do
      head do
        head_elements.each do |e|
          e.call
        end
      end
      # body content here
      body do
        text content
      end
    end
  end
end

class Hello < Page
  def initialize
    super
    head_elements << lambda do
      title "Hello"
    end
    head_elements << lambda do
      link :type=>"text/css", :rel=>"stylesheet", :href=>"/page.css"
    end
    @content = "Hey"
  end
  
end

puts Hello.new
