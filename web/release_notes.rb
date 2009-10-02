dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"

require "rdoc/rdoc"

require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_html'

class ReleaseNotes < Page
  def initialize
    super(:page_title => "Release Notes")
  end
  
  def render_body
    notes = File.read("#{File.dirname(__FILE__)}/../History.txt")
    notes.gsub!(/^== *$/, '')
    p = SM::SimpleMarkup.new
    h = SM::ToHtml.new
    notes = p.convert(notes, h)
    rawtext notes 
  end
end