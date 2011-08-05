dir = File.dirname(__FILE__)
require "#{dir}/section"

class Article < Erector::Widget
  
  def initialize(title, sections = [])
    super({})
    @title = title
    @sections = sections
  end
  
  def <<(section)
    @sections << section
    self
  end
  
  def content
    table_of_contents
    sections
  end
  
  def table_of_contents
    div.toc do
      h2 @title
      ol.toc do
        @sections.each do |section|
          li do
            a section.title, :href => "##{section.href}"
          end
        end
      end
    end
    div.clear
  end
  
  def sections
    @sections.each do |section|
      a :name => section.href
      h2 section.title
      widget section
    end
  end
end

