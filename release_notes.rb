dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/navbar"

require "rubygems"
require "bundler"
Bundler.setup
require 'rdoc/markup'
require 'rdoc/markup/to_html'

class ReleaseNotes < Page
  def initialize
    super(:page_title => "Release Notes")
  end
  
  def body_content
    notes = File.read("#{File.dirname(__FILE__)}/../History.txt")
    notes.gsub!(/^== *$/, '')
    notes = RDoc::Markup::ToHtml.new.convert(notes)
    rawtext notes 
  end
end
