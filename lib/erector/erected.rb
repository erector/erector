require 'rubygems'
require 'treetop'
dir = File.dirname(__FILE__)
require "#{dir}/indenting"
Treetop.load "#{dir}/../../lib/erector/rhtml"

module Erector
  class Erected
    def initialize(in_file)
      @in_file = in_file
    end

    def filename
      dir + basename + ".rb"
    end

    def classname
      base = classize(basename)
      parent = File.dirname(@in_file)
      grandparent = File.dirname(parent)
      if File.basename(grandparent) == "views"
        base = "Views::" + classize(File.basename(parent)) + "::" + base
      end
      base
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
          f.puts("class #{classname} < Erector::Widget")
          f.puts("  def render")
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