require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require "erector/rails"
require "rails/version"

# backport mktmpdir so this test will work on Ruby 1.8.6
unless Dir.respond_to?(:mktmpdir)
  def Dir.mktmpdir(prefix_suffix=nil, tmpdir=nil)
    case prefix_suffix
    when nil
      prefix = "d"
      suffix = ""
    when String
      prefix = prefix_suffix
      suffix = ""
    when Array
      prefix = prefix_suffix[0]
      suffix = prefix_suffix[1]
    else
      raise ArgumentError, "unexpected prefix_suffix: #{prefix_suffix.inspect}"
    end
    tmpdir ||= Dir.tmpdir
    t = Time.now.strftime("%Y%m%d")
    n = nil
    begin
      path = "#{tmpdir}/#{prefix}#{t}-#{$$}-#{rand(0x100000000).to_s(36)}"
      path << "-#{n}" if n
      path << suffix
      Dir.mkdir(path, 0700)
    rescue Errno::EEXIST
      n ||= 0
      n += 1
      retry
    end

    if block_given?
      begin
        yield path
      ensure
        FileUtils.remove_entry_secure path
      end
    else
      path
    end
  end
end

# Note: this is *not* inside the rails_root since we're not testing
# Erector inside a rails app. We're testing that we can use the command-line
# converter tool on a newly generated scaffold app (like we brag about in the
# user guide).
#
module Erector
  describe "the Rails version" do
    it "should be #{Erector::Rails::RAILS_VERSION}" do
      ::Rails::VERSION::STRING.should == Erector::Rails::RAILS_VERSION
    end
  end

  describe "Erect in a Rails app" do
    def run(cmd)
      stderr_file = Dir.tmpdir + "/stderr.txt"
      stdout = IO.popen(cmd + " 2>#{stderr_file}") do |pipe|
        pipe.read
      end
      stderr = File.open(stderr_file) {|f| f.read}
      FileUtils.rm_f(stderr_file)
      if $?.exitstatus != 0
        raise "Command #{cmd} failed\nDIR:\n  #{Dir.getwd}\nSTDOUT:\n#{indent stdout}\nSTDERR:\n#{indent stderr}"
      else
        return stdout
      end
    end

    def indent(s)
      s.gsub(/^/, '  ')
    end

    it "works like we say it does in the user guide" do
      erector_dir = File.expand_path("#{File.dirname(__FILE__)}/../..")

      # We add the paths to our vendored copy of rails to the load paths, so
      # that this spec can be run without having a version of Rails (which may
      # not match the version we wish to test against) installed.
      rails_libs_argument = "-I'#{RAILS_LOAD_PATHS.join("':'")}'"

      Dir.mktmpdir do |app_dir|
        run "ruby #{rails_libs_argument} '#{VENDOR_RAILS}/railties/bin/rails' '#{app_dir}'"

        FileUtils.cp_r(VENDOR_RAILS, "#{app_dir}/vendor/rails")

        FileUtils.mkdir_p(app_dir + "/vendor/gems")
        FileUtils.cp_r(erector_dir, "#{app_dir}/vendor/gems/erector")

        FileUtils.cd(app_dir) do
          run "script/generate scaffold post title:string body:text published:boolean"

          # The 'erector' binary would normally have been installed through rubygems,
          # providing it with a wrapper script which requires rubygems. But here we
          # run it directly, so we need to require rubygems explicitly before running
          # the main script.
          run "ruby #{rails_libs_argument} -I'#{erector_dir}/lib' " +
            "-e \"require 'rubygems'; load '#{erector_dir}/bin/erector'\" app/views/posts"

          FileUtils.rm_f("app/views/posts/*.erb")
          run "rake --trace db:migrate"

          # run "script/server" # todo: launch in background; use mechanize or something to crawl it; then kill it
          # perhaps use open4?
          # open http://localhost:3000/posts
        end
      end
    end
  end
end
