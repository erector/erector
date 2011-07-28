puts "RUBY_VERSION=#{RUBY_VERSION}"

begin
  # fix http://stackoverflow.com/questions/4932881/gemcutter-rake-build-now-throws-undefined-method-write-for-syckemitter
  require 'psych' unless RUBY_VERSION =~ /^1\.8/
rescue LoadError
  warn "Couldn't find psych; continuing."
end

require "bundler"
Bundler.setup

require 'rake'
require 'rake/testtask'

require "rspec/core/rake_task"

require 'rdoc'
here = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift("#{here}/lib")

require "erector/version"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.version = Erector::VERSION
    gemspec.name = "erector"
    gemspec.summary = "HTML/XML Builder library"
    gemspec.email = "erector@googlegroups.com"
    gemspec.description = "Erector is a Builder-like view framework, inspired by Markaby but overcoming some of its flaws. In Erector all views are objects, not template files, which allows the full power of object-oriented programming (inheritance, modular decomposition, encapsulation) in views."
    gemspec.files = FileList[
      "README.txt",
      "VERSION.yml",
      "lib/**/*",
      "bin/erector",
    ]
    gemspec.executables = ["erector"]
    specs = Dir.glob("spec/**/*") #.reject { |file| file =~ %r{spec/rails2/} }
    gemspec.test_files = ([
      "Rakefile",
      "Gemfile",
    ] + specs).flatten
    gemspec.homepage = "http://erector.rubyforge.org/"
    gemspec.authors = [
            "Alex Chaffee",
            "Brian Takita",
            "Jeff Dean",
            "Jim Kingdon",
            "John Firebaugh",
    ]
    # gemspec.add_dependency 'treetop', ">= 1.2.3" # Jeweler now reads Gemfile, I think
  end

  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
    rubyforge.remote_doc_path = "rdoc"
  end

rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end

desc "Default: run most tests"
task :default => :spec
task :cruise => [:install_gems, :print_environment, :test]
task :test => :spec

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


require 'rdoc/task'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "Erector #{Erector::VERSION}"
  rdoc.options << '--inline-source' << "--promiscuous"
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
  end

  desc "Run specs for the 'erector' command line tool."
  RSpec::Core::RakeTask.new(:erect) do |spec|
    spec.pattern = 'spec/erect/*_spec.rb'
  end

  desc "Run specs for erector's Rails integration."
  RSpec::Core::RakeTask.new(:rails) do |spec|
    spec.pattern = 'spec/rails_root/spec/*_spec.rb'
  end

  desc "Run specs for erector's Rails integration."
  RSpec::Core::RakeTask.new(:layout) do |spec|
    spec.pattern = 'spec/rails_root/spec/layout_spec.rb'
  end

  desc "Run specs for erector's Rails integration under Rails 2."
  task :rails2 do
    rails_app = "#{here}/spec/rails2/rails_app"
    gemfile = "#{rails_app}/Gemfile"
    Dir.chdir(rails_app) do
      # Bundler.with_clean_env do
        sh "BUNDLE_GEMFILE='#{gemfile}' bundle exec rake rails2"
      # end
    end
  end

  desc "Run all specs under Rails 3.1 - prepare with 'bundle install --gemfile Gemfile-rails31'"
  task :rails31 do
    gemfile = "#{here}/Gemfile-rails31"
    sh "BUNDLE_GEMFILE='#{gemfile}' bundle exec rake spec:core spec:erect spec:rails"
  end
end

desc "Run most specs"
task :spec => ['spec:core', 'spec:erect', 'spec:rails', 'spec:rails2']
