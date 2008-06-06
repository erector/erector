require "rubygems"
dir = File.dirname(__FILE__)
require 'cgi'
require "activesupport"
require "#{dir}/erector/extensions/object"
require "#{dir}/erector/doc"
require "#{dir}/erector/raw_string"
require "#{dir}/erector/widget"
require "#{dir}/erector/widgets"
if Object.const_defined?(:RAILS_ROOT)
  require "#{dir}/erector/rails"
end

##
# Erector view framework
module Erector
  VERSION = "0.3.110"
end
