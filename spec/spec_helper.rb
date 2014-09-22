require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]

require 'erector'
require 'rspec'

Dir[File.join(File.dirname(__FILE__), "../spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # nada
end
