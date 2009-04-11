dir = File.dirname(__FILE__)
require "rubygems"
$LOAD_PATH.unshift("#{dir}/../lib")
require "erector"
require "hpricot"
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
