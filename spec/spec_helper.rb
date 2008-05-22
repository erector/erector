dir = File.dirname(__FILE__)
require "rubygems"
require "active_record"
require "spec"
require "#{dir}/view_caching"
$LOAD_PATH.unshift("#{dir}/../lib")
require "erector"
require "erector/rails"
require "hpricot"
require "action_controller/test_process"

Spec::Runner.configure do |config|
  config.include ViewCaching
end
