puts "RUBY_VERSION=#{RUBY_VERSION}"
require 'rubygems'

begin
  require 'bundler'
rescue LoadError
  puts "bundler not found; attempting shell install of bundler"
  sh "which ruby"
  sh "gem install bundler"
  require 'bundler'
end

begin
  Bundler.setup
rescue Bundler::BundlerError => e
  puts "$USER is #{ENV['USER']}"
  puts "Bundler.setup failed with BundlerError: #{e.message}"
  puts "Attempting shell install of gem bundle"
  sh "echo USER=$USER && which ruby && ruby --version && which bundle"
  sh "bundle install"
  Bundler.setup
end

require 'rake'
require 'rake/testtask'
require 'hanna/rdoctask'
require 'rake/gempackagetask'
require "rspec/core/rake_task"

require 'rdoc'

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")

require "erector/version"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "erector"
    gemspec.summary = "Html Builder library."
    gemspec.email = "erector@googlegroups.com"
    gemspec.description = "Erector is a Builder-like view framework, inspired by Markaby but overcoming some of its flaws. In Erector all views are objects, not template files, which allows the full power of object-oriented programming (inheritance, modular decomposition, encapsulation) in views."
    specs = Dir.glob("spec/**/*").reject { |file| file =~ %r{^spec/rails_root} }
    gemspec.files = FileList[
            "lib/**/*",
            "README.txt", "VERSION.yml",
            "bin/erector",
    ]
    gemspec.executables = ["erector"]
    gemspec.test_files =  specs
    gemspec.homepage = "http://erector.rubyforge.org/"
    gemspec.authors = [
            "Alex Chaffee",
            "Brian Takita",
            "Jeff Dean",
            "Jim Kingdon",
    ]
    gemspec.add_dependency 'treetop', ">= 1.2.3"
    gemspec.add_dependency 'rake'
    gemspec.rubyforge_project = "erector"
  end

  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
    rubyforge.remote_doc_path = "rdoc"
  end

rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end

desc "Default: run tests"
task :default => :spec

task :test => :spec

task :cruise => [:install_gems, :print_environment, :test]

task :install_gems do
  sh "bundle check"
end

desc "Build the web site from the .rb files in web/"
task :web do
  files = Dir["web/*.rb"] - ["web/page.rb", "web/sidebar.rb", "web/clickable_li.rb"]
  require 'erector'
  require 'erector/erect/erect'
  $: << "."
  Erector::Widget.prettyprint_default = true
  Erector::Erect.new(["--to-html", * files]).run
end

desc "Generate rdoc"
task :docs => :rdoc

task :rdoc => :clean_rdoc
task :clean_rdoc do
  FileUtils.rm_rf("rdoc")
end

# push the docs to Rubyforge
task :publish_docs => :"rubyforge:release:docs"

desc "Publish web site to RubyForge"
task :publish_web do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  rubyforge_name = "erector"
  remote_dir = "/var/www/gforge-projects/#{rubyforge_name}"
  local_dir = "web"
  rdoc_dir = "rdoc"
  rsync_args = '--archive --verbose --delete'

  sh %{rsync #{rsync_args} --exclude=#{rdoc_dir} #{local_dir}/ #{host}:#{remote_dir}}
end

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "Erector #{Erector::VERSION}"
  rdoc.options << '--inline-source' << "--promiscuous"
  rdoc.options << "--template=hanna"
  rdoc.options << "--main=README.txt"
#  rdoc.options << '--diagram' if RUBY_PLATFORM !~ /win32/ and `which dot` =~ /\/dot/ and not ENV['NODOT']
  rdoc.rdoc_files.include('README.txt')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('bin/**/*')
end

desc "Regenerate unicode.rb from UnicodeData.txt from unicode.org.  Only needs to be run when there is a new version of the Unicode specification"
task(:build_unicode) do
  require 'lib/erector/unicode_builder'
  builder = Erector::UnicodeBuilder.new(
          File.open("/usr/lib/perl5/5.8.8/unicore/UnicodeData.txt"),
          File.open("lib/erector/unicode.rb", "w")
  )
  builder.generate
end

task :print_environment do
  puts <<-ENVIRONMENT
Build environment:
     #{`uname -a`.chomp}
  #{`ruby -v`.chomp}
  SQLite3:    #{`sqlite3 -version`}
  #{`gem env`}
Local gems:
   #{`gem list`.gsub(/^/, '  ')}
  ENVIRONMENT
end

namespace :spec do
  desc "Run core specs."
  RSpec::Core::RakeTask.new(:core) do |spec|
    spec.pattern = 'spec/erector/*_spec.rb'
    spec.rspec_opts = ['--backtrace']
  end

  desc "Run specs for the 'erector' command line tool."
  RSpec::Core::RakeTask.new(:erect) do |spec|
    spec.pattern = 'spec/erect/*_spec.rb'
    spec.rspec_opts = ['--backtrace']
  end

  desc "Run specs for erector's Rails integration."
  RSpec::Core::RakeTask.new(:rails) do |spec|
    spec.pattern = 'spec/rails_root/spec/*_spec.rb'
    spec.rspec_opts = ['--backtrace']
  end
end

desc "Run the specs for the erector plugin"
task :spec => ['spec:core', 'spec:erect', 'spec:rails']
