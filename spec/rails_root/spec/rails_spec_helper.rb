ENV["RAILS_ENV"] ||= "test"
ENV["BUNDLE_GEMFILE"] ||= "#{File.dirname(__FILE__)}/../Gemfile"

require File.expand_path("../../../spec_helper", __FILE__)
require File.expand_path("../../config/environment", __FILE__)

Bundler.require(:test)

require "erector/rails"
