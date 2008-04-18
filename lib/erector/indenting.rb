require 'rubygems'
require 'treetop'

dir = File.dirname(__FILE__)
require "#{dir}/../../lib/erector/rhtml"

module Erector
  class Indenting < Treetop::Runtime::SyntaxNode
    @@indent = 0

    def set_indent(x)
      @@indent = x
      self
    end

    def indent
      [0, @@indent].max
    end

    def indented(s)
      "  " * indent + s + "\n"
    end

    def line(s)
      indented(s)
    end

    def line_in(s)
      s = indented(s)
      @@indent += 1
      s
    end

    def line_out(s)
      @@indent -= 1
      indented(s)
    end
  end
end
