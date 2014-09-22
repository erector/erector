require 'spec_helper'
ENV["RAILS_ENV"] ||= "test"
require File.join(File.dirname(__FILE__), "dummy/config/environment")
Bundler.require(:test)

# Re-require the Rails-y part of Erector
require "erector/rails"
