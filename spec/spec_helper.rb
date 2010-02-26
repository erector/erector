require "rubygems"
dir = File.dirname(__FILE__)
$LOAD_PATH.unshift("#{dir}/../lib")
require "erector"
require "nokogiri"
require "rr"
require 'tempfile'
require 'ostruct'
ARGV.push(*File.read("#{File.dirname(__FILE__)}/spec.opts").split("\n"))
require "spec"
require "spec/autorun"

Spec::Runner.configure do |config|
  config.mock_with :rr
end

# This mimics Rails load path and dependency stuff
RAILS_ROOT = File.expand_path("#{File.dirname(__FILE__)}/rails_root") unless defined?(RAILS_ROOT)
#$: << "#{RAILS_ROOT}/app"
module Views
  module TemplateHandlerSpec
  end
end


# uncomment this to find leftover debug putses
#
# alias :original_puts :puts
# def puts(string ="")
#   super string.to_s + "\s(#{caller.first.match(/(\w+\.\w+:\d+)|Rakefile:\d+/)[0]})"
# end
# 
# alias :original_p :p
# def p(string="")
#   original_puts "\s(#{caller.first.match(/(\w+\.\w+:\d+)|Rakefile:\d+/)[0]})"
#   super(string)
# end
# 
# alias :original_print :print
# def print(string="")
#   super string + "\s(#{caller.first.match(/(\w+\.\w+:\d+)|Rakefile:\d+/)[0]})"
# end
unless '1.9'.respond_to?(:force_encoding)
  String.class_eval do
    begin
      remove_method :chars
    rescue NameError
      # OK
    end
  end
end

module Matchers
  # borrowed from http://github.com/aiwilliams/spec_goodies

  class IncludeOnly # :nodoc:all
    def initialize(*expected)
      @expected = expected.flatten
    end

    def matches?(actual)
      @missing = @expected.reject {|e| actual.include?(e)}
      @extra = actual.reject {|e| @expected.include?(e)}
      @extra.empty? && @missing.empty?
    end

    def failure_message
      message = "expected to include only #{@expected.inspect}"
      message << "\nextra: #{@extra.inspect}" unless @extra.empty?
      message << "\nmissing: #{@missing.inspect}" unless @missing.empty?
      message
    end

    def negative_failure_message
      "expected to include more than #{@expected.inspect}"
    end

    def to_s
      "include only #{@expected.inspect}"
    end
  end

  # Unlike checking that two Enumerables are equal, where the
  # objects in corresponding positions must be equal, this will
  # allow you to ensure that an Enumerable has all the objects
  # you expect, in any order; no more, no less.
  def include_only(*expected)
    IncludeOnly.new(*expected)
  end
end

Spec::Runner.configure do |config|
  include Matchers
end
