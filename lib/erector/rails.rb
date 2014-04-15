require 'rails/version'
if Rails::VERSION::MAJOR == 2
  require 'erector/rails2'
elsif Rails::VERSION::MAJOR == 3
  require 'erector/rails3'
else
  exit "Rails 4 not yet supported"
  require 'erector/rails4'
end
