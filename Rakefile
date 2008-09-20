require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require './tasks/hoex.rb'  # Alex's patched version of Hoe

dir = File.dirname(__FILE__)
$: << "#{dir}/lib"
require "erector/version"

GEM_VERSION = Erector::VERSION # defined in lib/erector/version.rb
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
task :spec do
  rails_root = "#{File.dirname(__FILE__)}/spec/rails_root"
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
  require "lib/erector/rails/supported_rails_versions"
  system("git clone git://github.com/rails/rails.git spec/rails_root/vendor/rails_versions/edge") || raise("Git clone of Rails failed")
  require "fileutils"
  edge_path = "spec/rails_root/vendor/rails_versions/edge"
  FileUtils.mkdir_p(edge_path)
  Dir.chdir(edge_path) do
    begin
      Erector::Rails::SUPPORTED_RAILS_VERSIONS.each do |version, data|
        unless version == 'edge'
          system("git checkout #{data['git_tag']}")
          system("cp -R ../edge ../#{version}")
        end
      end
    ensure
      system("git checkout master")
    end
  end
end

desc "Updates the dependencies to run the build. This task uses Git."
task(:update_dependencies) do
  system "cd spec/rails_root/vendor/rails_versions/edge; git pull origin"
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

