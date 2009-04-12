# Don't change this file. Configuration is done in config/environment.rb and config/environments/*.rb

unless defined?(RAILS_ROOT)
  root_path = File.join(File.dirname(__FILE__), '..')

  unless RUBY_PLATFORM =~ /(:?mswin|mingw)/
    require 'pathname'
    root_path = Pathname.new(root_path).cleanpath(true).to_s
  end

  RAILS_ROOT = root_path
end

unless defined?(Rails::Initializer)
  rails_dir = "#{RAILS_ROOT}/vendor/rails"

  Dir["#{rails_dir}/*"].each do |path|
    $:.unshift("#{path}/lib") if File.directory?("#{path}/lib")
  end
  initializer_path = "#{rails_dir}/railties/lib/initializer.rb"
  unless File.exists?(initializer_path)
    raise "#{initializer_path} not in vendor. Run rake install_dependencies"
  end

  require "#{rails_dir}/railties/environments/boot"

  Rails::Initializer.run(:set_load_path)
end
