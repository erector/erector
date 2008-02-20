$: << "../lib"
require 'erector'

class Head < Erector::Widget
  attr_reader :elements
  attr_accessor :title

  def initialize
    super
    @elements = []
    @elements << Erector::Widget.new do
      title @title if @title
    end
  end

  def <<(element)
    @elements << element
  end
  
  def render
    head do
      elements.each do |e|
        e.render_to(doc)
      end
    end
  end
end

class Page < Erector::Widget
  attr_accessor :content
  attr_reader :head
  
  def initialize
    super
    @head = Head.new
  end

  def render
    instruct
    html do
      head.render_for(self)
      body do
        text content
      end
    end
  end
end

class Hello < Page
  def initialize
    super
    head << Erector::Widget.new do
      title "Hello"
    end
    head << Erector::Widget.new do
      link :type=>"text/css", :rel=>"stylesheet", :href=>"/page.css"
    end
    @content = "Hey"
  end
  
end

puts Hello.new
