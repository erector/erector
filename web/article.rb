require 'erector'
here = File.expand_path(File.dirname(__FILE__))
require "#{here}/section"

# todo: move this to Erector::Widgets (aka ErectorSet)
class Article < Erector::Widget
  needs :name, :sections => []
  
  def <<(section)
    @sections << section
    self
  end
  
  def add(options, &block)
    Section.new(options, &block).tap do |sec|
      self << sec
    end
  end

  def content
    div.article {
      output.newline
      h1.name @name
      table_of_contents if @sections.size > 1
      emit_sections if @sections.size > 0
    }
  end
  
  def table_of_contents
    div.toc do
      h2 "Table of Contents"
      toc_items(@sections)
    end
    div.clear
  end

  def toc_items sections
    output.newline unless output.at_line_start?
    ol.toc do
      sections.each do |section|
        li do
          a section.name, :href => "##{section.href}"
          if section.sections?
            toc_items section.sections
          end
        end
      end
    end
  end

  def emit_sections sections = @sections, prefix = "", level = 0
    div.sections {
      output.newline unless output.at_line_start?
      sections.each_with_index do |section,i|
        a :name => section.href
        header_method = "h#{level+2}"
        self.send(header_method) {
          text prefix, (i+1), '. ', section.name
        }
        widget section
        
        if section.sections?
          output.newline unless output.at_line_start?
          emit_sections section.sections, "#{prefix}#{i+1}.", level + 1
        end
      end
    }
  end
end

