require File.expand_path("#{File.dirname(__FILE__)}/../rails_spec_helper")

module Erector

  describe "Erect in a Rails app" do
    
    attr_reader :dir
    
    def create(file, body="hi")
      File.open(file, "w") do |f|
        f.puts(body)
      end
    end
    
    def run(cmd)
      puts cmd
      output = `#{cmd}`
      if $? != 0
        raise "Command #{cmd} failed: #{output}"
      else
        return output
      end
    end
    
    it "works like we say it does in the user guide" do
      @dir = Dir.tmpdir + "/#{Time.now.to_i}" + "/explode"
      @bin = ("#{File.dirname(__FILE__)}/../../../../bin")
      
      FileUtils.mkdir_p(dir)
      run "rails #{@dir}"
      FileUtils.cd(@dir, :verbose => true) do
        run "script/generate scaffold post title:string body:text published:boolean"
        run "#{@bin}/erector app/views/posts"
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
