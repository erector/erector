dir = File.dirname(__FILE__)
require "rubygems"
require "active_record"
require "spec"
$LOAD_PATH.unshift("#{dir}/../lib")
require "erector"
require "erector/rails"
require "hpricot"
require "action_controller/test_process"
require "rr"
require 'tempfile'
require 'ostruct'
require 'treetop'
require "erector/erect"
require "erector/erected"


Spec::Runner.configure do |config|
  config.mock_with :rr
end

# This mimics Rails load path and dependency stuff
RAILS_ROOT = File.expand_path("#{File.dirname(__FILE__)}/rails/rails_root") unless defined?(RAILS_ROOT)
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
