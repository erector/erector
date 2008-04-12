#!/usr/local/bin/ruby
dir = File.dirname(__FILE__)

require 'rubygems'
require 'treetop'
Treetop.load "#{dir}/../lib/erector/html_erb"

parser = HtmlErbParser.new

ARGV.each do |file|
  puts file
  text = File.read(file)
  puts text
  puts "---"
  parsed = parser.parse(File.read(file))
  if parsed.nil?
    puts parser.terminal_failures.join("\n")
  else
    puts parsed.convert
  end
end
