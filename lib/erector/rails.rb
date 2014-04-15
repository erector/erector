require 'rails/version'
if Rails::VERSION::MAJOR == 3
  require 'erector/rails3'
elsif Rails::VERSION::MAJOR == 4
  raise "Rails 4 not yet supported"
  require 'erector/rails4'
else
  raise "erector/rails not loaded: #{Rails::VERSION} not supported"
end
