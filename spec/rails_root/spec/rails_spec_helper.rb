ENV["RAILS_ENV"] ||= "test"
dir = File.dirname(__FILE__)
$LOAD_PATH.unshift("#{dir}/../../../lib")
require "#{dir}/../config/environment"

RAILS_VERSION = File.basename(`ls -l #{dir}/../vendor/rails`.split(" -> ").last)

require "action_controller/test_process"
require "spec"
require "spec/autorun"
require "hpricot"
require "rr"
require "rr/adapters/rspec"

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end

unless '1.9'.respond_to?(:force_encoding)
  String.class_eval do
    begin
      remove_method :chars
    rescue NameError
      # OK
    end
  end
end