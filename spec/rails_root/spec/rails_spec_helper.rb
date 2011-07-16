ENV["RAILS_ENV"] ||= "test"
ENV["BUNDLE_GEMFILE"] ||= "#{File.dirname(__FILE__)}/../Gemfile"

here = File.expand_path(File.dirname(__FILE__))
require File.expand_path("#{here}/../../spec_helper", __FILE__)
require File.expand_path("#{here}/../config/environment", __FILE__)

Bundler.require(:test)

require "erector/rails"
