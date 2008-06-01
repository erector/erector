require "rubygems"
dir = File.dirname(__FILE__)

require 'cgi'
require "#{dir}/erector/extensions/object"
require "#{dir}/erector/doc"
require "#{dir}/erector/raw_string"
require "#{dir}/erector/widget"
require "#{dir}/erector/widgets"
require "#{dir}/erector/rails"

##
# Erector view framework
module Erector
  VERSION = "0.3.110"
end
