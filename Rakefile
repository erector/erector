require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require './tasks/hoex.rb'  # Alex's patched version of Hoe

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")

require "erector/version"

gem_definition = lambda do |s|
  s.name = "erector"
  s.summary = "Html Builder library."
  s.email = "erector@googlegroups.com"
  s.description = "Html Builder library."
  specs = Dir.glob("spec/**/*").reject{|file| file =~ %r{^spec/rails_root}}
  s.files =  ["lib/**/*", "rails/init.rb", "README.txt", "VERSION.yml", "bin/erector", specs]
  s.test_files =  specs
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    gem_definition.call(s)
    s.homepage = "http://erector.rubyforge.org/"
    s.authors = [
      "Alex Chaffee",
      "Brian Takita",
      "Jeff Dean",
      "Jim Kingdon",
    ]
    s.add_dependency 'treetop', ">= 1.2.3"
    s.rubyforge_project = "erector"
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Hoe.new("erector", Erector::VERSION) do |hoe|
  gem_definition.call(hoe)
  hoe.developer("Pivotal Labs", "pivotallabsopensource@googlegroups.com")
  hoe.rdoc_dir = "rdoc"
  hoe.remote_rdoc_dir = "rdoc"

  # Many of these options are based on what will work with rubyforge and
  # groups and permissions
  hoe.rsync_args = "-rlv --delete --inplace --exclude .svn"
end
Hoe::remove_tasks("audit", "check_manifest", "post_blog", "multi", "test", "test_deps", "docs")

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
  require 'erector/erect'
  Erector::Widget.prettyprint_default = true
  Erector::Erect.new(["--to-html", *files]).run
end

desc "Generate rdoc"
task :docs do
  FileUtils.rm_rf("rdoc")
  options = %w(-o rdoc --inline-source --main README.txt)
  options << "-t \"Erector #{Erector::VERSION}\""
  options << '-d' if RUBY_PLATFORM !~ /win32/ and `which dot` =~ /\/dot/ and not ENV['NODOT']
  system "rdoc #{options.join(" ")} lib bin README.txt"
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
  SQLite3: #{`sqlite3 -version`}
#{`gem env`}
Local gems:
#{`gem list`.gsub(/^/, '  ')}
  ENVIRONMENT
end

namespace :spec do
  Spec::Rake::SpecTask.new(:core) do |spec|
    spec.spec_files = FileList['spec/erector/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:erect) do |spec|
    spec.spec_files = FileList['spec/erect/*_spec.rb']
  end
  task :erect => :clone_rails

  Spec::Rake::SpecTask.new(:rails) do |spec|
    spec.spec_files = FileList['spec/rails_root/spec/*_spec.rb']
  end
  task :rails => :clone_rails
end

desc "Run the specs for the erector plugin"
task :spec => ['spec:core', 'spec:erect', 'spec:rails']
