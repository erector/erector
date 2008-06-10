ENV["RAILS_ENV"] ||= "test"
dir = File.dirname(__FILE__)
$LOAD_PATH.unshift("#{dir}/../../../lib")
require "#{dir}/../config/environment"

require "action_controller/test_process"
require "spec"
require "rr"
require "rr/adapters/rspec"

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end
