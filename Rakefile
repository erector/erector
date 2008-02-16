require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'
require 'spec/rake/spectask'
require 'rake/gempackagetask'


require './tasks/hoex.rb'

GEM_VERSION = "0.1.0"
GEM_NAME = "erector"

Hoe.new(GEM_NAME, GEM_VERSION) do |hoe|
  hoe.name = GEM_NAME
  hoe.developer("Pivotal Labs", "alex@pivotallabs.com")
  hoe.rdoc_dir = "rdoc"
  hoe.remote_rdoc_dir = "rdoc"
  hoe.files = ["{spec,lib}/**/*", "README.txt"]
end
Hoe::remove_tasks("audit", "check_manifest", "post_blog", "multi", "test", "test_deps")


desc 'Default: run unit tests.'
task :default => :spec

task :test => :spec

desc "Run the specs for the erector plugin"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

# desc 'Generate documentation for the widgets plugin.'
# Rake::RDocTask.new(:rdoc) do |rdoc|
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title    = 'Widgets'
#   rdoc.options << '--line-numbers' << '--inline-source'
#   rdoc.rdoc_files.include('README.txt')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end
# 
# gemspec = Gem::Specification.new do |s|
#   s.name = PROJECT_NAME
#   s.version = GEM_VERSION
#   s.author = "Pivotal Labs"
#   s.summary = "An object oriented HTML generation framework"
#   s.platform = Gem::Platform::RUBY
#   s.files = FileList["Rakefile", "{spec,lib}/**/*"].to_a
#   s.require_path = "lib"
#   s.autorequire = "treetop"
#   s.has_rdoc = true
# end
# 
# Rake::GemPackageTask.new(gemspec) do |pkg|
#   pkg.need_tar = true
# end
