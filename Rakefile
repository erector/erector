require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require './tasks/hoex.rb'  # Alex's patched version of Hoe

dir = File.dirname(__FILE__)
$: << "#{dir}/lib"
require "erector"
require "erector/erect"

GEM_VERSION = Erector::VERSION # defined in lib/erector.rb
GEM_NAME = "erector"

Hoe.new(GEM_NAME, GEM_VERSION) do |hoe|
  hoe.name = GEM_NAME
  hoe.developer("Pivotal Labs", "alex@pivotallabs.com")
  hoe.rdoc_dir = "rdoc"
  hoe.remote_rdoc_dir = "rdoc"
  hoe.files = ["{spec,lib}/**/*", "README.txt", "bin/erect"]
  hoe.extra_deps = [['treetop', ">= 1.2.3"], "rake"]
end
Hoe::remove_tasks("audit", "check_manifest", "post_blog", "multi", "test", "test_deps", "docs")

desc "Default: run tests"
task :default => :spec

task :test => :spec

task :cruise => [:geminstaller, :test]

task :geminstaller do
  system "geminstaller --sudo"
end

desc "Run the specs for the erector plugin"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Build the web site from the .rb files in web/"
task :web do
  dir = File.dirname(__FILE__)
  files = Dir["web/*.rb"] - ["web/page.rb", "web/sidebar.rb"]
  Erector::Erect.new([
    "--to-html",
    *files
  ]).run
end

desc "Generate rdoc"
task :docs do
  FileUtils.rm_rf("rdoc")
  options = %w(-o rdoc --inline-source --main README.txt)
  options << "-t \"Erector #{Erector::VERSION}\""
  options << '-d' if RUBY_PLATFORM !~ /win32/ and `which dot` =~ /\/dot/ and not ENV['NODOT']
  system "rdoc #{options.join(" ")} lib bin README.txt"
end
