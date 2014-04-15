puts "RUBY_VERSION=#{RUBY_VERSION}"

begin
  # fix http://stackoverflow.com/questions/4932881/gemcutter-rake-build-now-throws-undefined-method-write-for-syckemitter
  require 'psych' unless RUBY_VERSION =~ /^1\.8/
rescue LoadError
  warn "Couldn't find psych; continuing."
end

require "bundler"
Bundler.setup
require "bundler/gem_tasks"

require 'rake'
require 'rake/testtask'
require "rspec/core/rake_task"
require 'rdoc'

here = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift("#{here}/lib")

require "erector/version"

# Tasks

desc "Default: run most tests"
task :default => :spec
task :cruise => [:install_gems, :print_environment, :test]
task :test => :spec

task :install_gems do
  sh "bundle check"
end

desc "Build the web site from the .rb files in web/"
task :web do
  files = Dir["web/*.rb"].select do |filename|
    File.read(filename) =~ (/\< Page/)
  end
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

desc "Publish web site and docs to RubyForge"
task :publish => [:web, :docs] do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  rubyforge_name = "erector"
  remote_dir = "/var/www/gforge-projects/#{rubyforge_name}"
  local_dir = "web"
  rdoc_dir = "rdoc"
  rsync_args = '--archive --verbose --delete'

  puts "== Publishing web site to RubyForge"
  sh %{rsync #{rsync_args} --exclude=#{rdoc_dir} #{local_dir}/ #{host}:#{remote_dir}}

  puts "== Publishing rdoc to RubyForge"
  sh %{rsync #{rsync_args} #{rdoc_dir}/ #{host}:#{remote_dir}/rdoc}
end


begin
require 'rdoc/task'
  RDoc::Task.new(:rdoc) do |rdoc|
    rdoc.rdoc_dir = 'rdoc'
    rdoc.title    = "Erector #{Erector::VERSION}"
    rdoc.options <<
      "--main=README.txt"
    rdoc.rdoc_files.include('README.txt')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('bin/**/*')
  end
rescue LoadError => e
  puts "#{e.class}: #{e.message}"
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
  end

  desc "Run specs for the 'erector' command line tool."
  RSpec::Core::RakeTask.new(:erect) do |spec|
    spec.pattern = 'spec/erect/*_spec.rb'
  end

  desc "Run specs for erector's Rails 3 integration."
  RSpec::Core::RakeTask.new(:integration_rails3) do |spec|
    spec.pattern = 'spec/rails_root/spec/*_spec.rb'
  end

  desc "Run specs for erector's Rails 4 integration."
  RSpec::Core::RakeTask.new(:integration_rails4) do |spec|
    spec.pattern = 'spec/rails_root/spec/*_spec.rb'
  end

  def prepare_gemfile gemfile
    Bundler.with_clean_env { sh "bundle check --gemfile #{gemfile} || bundle install --gemfile #{gemfile}" }
  end

  desc "Run all specs under Rails 3"
  task :rails3 do
    gemfile = "#{here}/Gemfile-rails31"
    prepare_gemfile gemfile
    sh "BUNDLE_GEMFILE='#{gemfile}' bundle exec rake spec:core spec:erect spec:integration_rails3"
  end

  desc "Run all specs under Rails 4"
  task :rails4 do
    gemfile = "#{here}/Gemfile-rails4"
    prepare_gemfile gemfile
    sh "BUNDLE_GEMFILE='#{gemfile}' bundle exec rake spec:core spec:erect spec:integration_rails4"
  end

  desc "Run all specs under latest Rails"
  task :rails => :rails4 do
    gemfile = "#{here}/Gemfile-rails"
    prepare_gemfile gemfile
    sh "BUNDLE_GEMFILE='#{gemfile}' bundle exec rake spec:core spec:erect spec:integration_rails3"
  end

  desc "Run specs for the Erector web site."
  RSpec::Core::RakeTask.new(:web) do |spec|
    spec.pattern = 'spec/web/*_spec.rb'
  end

end

desc "Run most specs"
task :spec => ['spec:rails', 'spec:rails3', 'spec:web']
