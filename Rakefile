require 'rubygems'
require 'bundler'
Bundler.setup

require 'rake'
require 'rake/testtask'
require 'hanna/rdoctask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
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
            "rails/init.rb",
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

task :cruise => [:geminstaller, :print_environment, :test]

task :geminstaller do
  require 'geminstaller'
  GemInstaller.run('--sudo --exceptions') || raise("GemInstaller failed")
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


desc "Clone the rails git repository and configure it for testing."
task(:clone_rails) do
  require "erector/rails/rails_version"

  rails_root = "#{File.dirname(__FILE__)}/spec/rails_root"
  vendor_rails = "#{rails_root}/vendor/rails"

  unless File.exists?("#{rails_root}/vendor/rails/.git")
    puts "Cloning rails into #{vendor_rails}"
    FileUtils.rm_rf(vendor_rails)

    # This is gross. The 'git' gem, which is invoked by Jeweler when we
    # define the Jeweler::Tasks.new instance above, has a habit of
    # setting GIT_DIRECTORY, etc.  environment variables, fixing git's
    # idea of what the repository is at the root of the 'erector' repo,
    # instead of using the target directory for the Rails clone. The
    # end result is that you get this really inscrutable error message:
    #
    # Cloning rails into spec/rails_root/vendor/rails
    # fatal: working tree '/Users/andrew/Documents/Active/Employment/Scribd/src.1/rails/vendor/plugins/ageweke-erector' already exists.
    # rake aborted!
    # Git clone of Rails failed
    #
    # So, we manually remove them from the environment just for this
    # clone. If you know a cleaner/better way of doing this, by all
    # means, change it here. Probably the 'git' gem shouldn't be
    # setting such variables in the first place, but it does.
    oldenv = ENV.dup
    ENV.keys.select { |k| k =~ /^GIT_/ }.each { |k| ENV.delete(k) }
    system("git clone git://github.com/rails/rails.git #{vendor_rails}") || raise("Git clone of Rails failed")
    ENV = oldenv
  end

  Dir.chdir(vendor_rails) do
    puts "Checking out rails #{Erector::Rails::RAILS_VERSION_TAG} into #{vendor_rails}"
    system("git fetch origin")
    system("git checkout #{Erector::Rails::RAILS_VERSION_TAG}")
  end
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
  Spec::Rake::SpecTask.new(:core) do |spec|
    spec.spec_files = FileList['spec/erector/*_spec.rb']
    spec.spec_opts = ['--backtrace']
  end

  desc "Run specs for the 'erector' command line tool."
  Spec::Rake::SpecTask.new(:erect) do |spec|
    spec.spec_files = FileList['spec/erect/*_spec.rb']
    spec.spec_opts = ['--backtrace']
  end
  task :erect => :clone_rails

  desc "Run specs for erector's Rails integration."
  Spec::Rake::SpecTask.new(:rails) do |spec|
    spec.spec_files = FileList['spec/rails_root/spec/*_spec.rb']
    spec.spec_opts = ['--backtrace']
  end
  task :rails => :clone_rails
end

desc "Run the specs for the erector plugin"
task :spec => ['spec:core', 'spec:erect', 'spec:rails']
