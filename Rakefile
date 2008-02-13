require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'
require 'spec/rake/spectask'
require 'rake/gempackagetask'

desc 'Default: run unit tests.'
task :default => :spec

desc "Run the specs for the erector plugin"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Generate documentation for the widgets plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Widgets'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

gemspec = Gem::Specification.new do |s|
  s.name = "erector"
  s.version = "0.0.1"
  s.author = "Pivotal Labs"
  s.summary = "An object oriented HTML generation framework"
  s.platform = Gem::Platform::RUBY
  s.files = FileList["Rakefile", "{spec,lib}/**/*"].to_a
  s.require_path = "lib"
  s.autorequire = "treetop"
  s.has_rdoc = true
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_tar = true
end