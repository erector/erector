dir = File.dirname(__FILE__)
require "#{dir}/section"

class Article < Erector::Widget
  attr_reader :sections
  
  def initialize(sections = [])
    super({})
    @sections = sections
  end
  
  def <<(section)
    @sections << section
    self
  end
  
  def content
    table_of_contents
    render_sections
  end
  
  def table_of_contents
    ul do
      sections.each do |section|
        li do
          a section.title, :href => "##{section.href}"
        end
      end
    end
  end
  
  def render_sections
    sections.each do |section|
      a :name => section.href
      h2 section.title
      widget section
    end
  end
end

