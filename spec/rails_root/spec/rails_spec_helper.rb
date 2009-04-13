ENV["RAILS_ENV"] ||= "test"
dir = File.dirname(__FILE__)
$LOAD_PATH.unshift("#{dir}/../../../lib")
Dir.chdir("#{dir}/../../..") do
  system("rake switch_to_rails_version_tag")
end
require "#{dir}/../config/environment"

require "action_controller/test_process"
ARGV.push(*File.read("#{File.dirname(__FILE__)}/../../spec.opts").split("\n"))
require "spec"
require "spec/autorun"
require "hpricot"
require "rr"
require "rr/adapters/rspec"
require 'treetop'
require "erector"
require "erector/erect"
require "erector/erected"

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