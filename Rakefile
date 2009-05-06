require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require './tasks/hoex.rb'  # Alex's patched version of Hoe

def rails_root
  "#{File.dirname(__FILE__)}/spec/rails_root"
end

dir = File.dirname(__FILE__)
$: << "#{dir}/lib"
require "erector/version"

gem_definition = lambda do |s|
  s.name = "erector"
  s.summary = "Html Builder library."
  s.email = "erector@googlegroups.com"
  s.description = "Html Builder library."
  specs = Dir.glob("spec/**/*").reject{|file| file =~ %r{^spec/rails_root}}
  s.files =  ["lib/**/*", "README.txt", "VERSION.yml", "bin/erector", specs]
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
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end


RAILS_PATH = "spec/rails_root/vendor/rails"
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

EDGE_PATH = "spec/rails_root/vendor/rails_versions/edge"

desc "Default: run tests"
task :default => :spec

task :test => :spec

task :cruise => [:geminstaller, :install_dependencies, :switch_to_rails_version_tag, :test]

task :geminstaller do
  require 'geminstaller'
  GemInstaller.run('--sudo --exceptions') || raise("GemInstaller failed")
end

desc "Run the specs for the erector plugin"
task :spec do
  unless File.exists?("#{rails_root}/vendor/rails/railties/lib/initializer.rb")
    warn "Rails not cloned into #{rails_root}. Installing dependencies."
    Rake.application[:install_dependencies].invoke
  end
  require "spec/spec_suite"
  SpecSuite.all
end

desc "Build the web site from the .rb files in web/"
task :web do
  dir = File.dirname(__FILE__)
  files = Dir["web/*.rb"] - ["web/page.rb", "web/sidebar.rb"]
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

desc "Install dependencies to run the build. This task uses Git."
task(:install_dependencies) do
  require "lib/erector/rails/rails_version"
  FileUtils.rm_rf(RAILS_PATH)
  system("git clone git://github.com/rails/rails.git #{RAILS_PATH}") || raise("Git clone of Rails failed")
  Rake.application[:switch_to_rails_version_tag].invoke
end

desc "Refreshes the Rails versions from edge git repo"
task(:switch_to_rails_version_tag) do
  require "lib/erector/rails/rails_version"
  Dir.chdir(RAILS_PATH) do
    system("git fetch origin")
    system("git checkout #{Erector::Rails::RAILS_VERSION_TAG}")
  end
end

desc "Updates the dependencies to run the build. This task uses Git."
task(:update_dependencies) do
  system "cd #{RAILS_PATH}; git fetch origin"
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
