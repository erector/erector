require "rubygems"
dir = File.dirname(__FILE__)
require 'cgi'
require "#{dir}/erector/extensions/object"
require "#{dir}/erector/raw_string"
require "#{dir}/erector/widget"
require "#{dir}/erector/unicode"
require "#{dir}/erector/widgets"
require "#{dir}/erector/version"
if Object.const_defined?(:RAILS_ROOT)
  require "#{dir}/erector/rails"
end

