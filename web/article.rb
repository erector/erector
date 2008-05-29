dir = File.dirname(__FILE__)
require "#{dir}/section"

class Article < Erector::Widget
  attr_reader :sections
  
  def initialize(sections = [])
    super
    @sections = sections
  end
  
  def <<(section)
    @sections << section
  end
  
  def render
    render_table_of_contents
    render_sections
  end
  
  def render_table_of_contents
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
      section.render_to(doc)
    end
  end
end

