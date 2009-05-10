require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

require "erector/rails"

# Note: this is *not* inside the rails_root since we're not testing 
# Erector inside a rails app. We're testing that we can use the command-line
# converter tool on a newly generated scaffold app (like we brag about in the 
# user guide).
#
module Erector

  describe "the user running this spec" do
    it "should have the correct Rails gem (version #{Erector::Rails::RAILS_VERSION}) installed" do
      target_version = Gem::Version.new(Erector::Rails::RAILS_VERSION)
      dep = Gem::Dependency.new "rails", target_version
      specs = Gem.source_index.search dep
      specs.size.should == 1
    end
  end

  describe "Erect in a Rails app" do
    
    def run(cmd)
      puts cmd
      stdout = `#{cmd}`
      if $? != 0
        raise "Command #{cmd} failed, returning '#{stdout}', current dir '#{Dir.getwd}'"
      else
        return stdout
      end
    end
    
    def run_rails(app_dir)
      # To ensure we're working with the right version of Rails we use "gem 'rails', 1.2.3"
      # in a "ruby -e" command line invocation of the rails executable to generate an
      # app called explode.
      #
      puts "Generating fresh rails #{Erector::Rails::RAILS_VERSION} app"
      run "ruby -e \"require 'rubygems'; gem 'rails', '#{Erector::Rails::RAILS_VERSION}'; load 'rails'\" #{app_dir}"
    end
      
    it "works like we say it does in the user guide" do
      app_dir = Dir.tmpdir + "/#{Time.now.to_i}" + "/explode"
      erector_bin = File.expand_path("#{File.dirname(__FILE__)}/../../bin")
      
      FileUtils.mkdir_p(app_dir)
      run_rails app_dir
      FileUtils.cd(app_dir, :verbose => true) do
        run "script/generate scaffold post title:string body:text published:boolean"
        run "#{erector_bin}/erector app/views/posts"
        FileUtils.rm_f("app/views/posts/*.erb")
        run "(echo ''; echo \"require 'erector'\") >> config/environment.rb"
        run "rake db:migrate"
        # run "script/server" # todo: launch in background; use mechanize or something to crawl it; then kill it
        # perhaps use open4?
        # open http://localhost:3000/posts
      end
    end
    
  end

end
