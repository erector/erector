require 'rails/version'
if Rails::VERSION::MAJOR == 2
  require 'erector/rails2'
else
  require 'erector/rails3'
end

