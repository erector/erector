require 'rubygems'
require 'treetop'
dir = File.dirname(__FILE__)
require "#{dir}/indenting"
Treetop.load("#{dir}/rhtml.treetop")

module Erector
  class Erected
    
    def initialize(in_file)
      @in_file = in_file
    end

    def filename
      dir + basename + ".rb"
    end

    def classnames
      base = classize(basename)
      parent = File.dirname(@in_file)
      grandparent = File.dirname(parent)
      if File.basename(grandparent) == "views"
        ["Views::" + classize(File.basename(parent)) + "::" + base, "Erector::RailsWidget"]
      else
        [base, "Erector::Widget"]
      end
    end

    def classname
      classnames[0]
    end
    
    def parent_class
      classnames[1]
    end

    def text
      File.read(@in_file)
    end

    def convert
      parser = RhtmlParser.new
      parsed = parser.parse(File.read(@in_file))
      if parsed.nil?
        raise "Could not parse #{@in_file}\n" +
          parser.failure_reason
      else
        File.open(filename, "w") do |f|
          f.puts("class #{classname} < #{parent_class}")
          f.puts("  def content")
          f.puts(parsed.set_indent(2).convert)
          f.puts("  end")
          f.puts("end")
        end
      end
    end

    protected

    def basename
      @in_file.split("/").last.gsub(/\..*$/, '')
    end

    def dir
      x = File.dirname(@in_file)
      return (x == ".") ? "" : "#{x}/"
    end

    def classize(filename)
      filename.split("_").map{|part| part.capitalize}.join
    end
  end
end