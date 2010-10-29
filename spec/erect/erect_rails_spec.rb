require File.expand_path("../../spec_helper", __FILE__)

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
describe "the 'erector' command" do
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
    erector_dir = File.expand_path("../../..", __FILE__)
    Dir.mktmpdir do |app_dir|
      FileUtils.cd(app_dir) do
        run "bundle exec rails new erector"

        File.open('erector/Gemfile', 'w') do |gemfile|
          gemfile.write <<-GEMFILE
            source 'http://rubygems.org'

            gem "rails", "~> 3.0.0"
            gem 'sqlite3-ruby', :require => 'sqlite3'
            gem "erector", :path => "#{erector_dir}"
          GEMFILE
        end

        FileUtils.cd('erector') do
          run "BUNDLE_GEMFILE=./Gemfile bundle install"
          run "BUNDLE_GEMFILE=./Gemfile bundle exec rails generate scaffold post title:string body:text published:boolean"
          run "BUNDLE_GEMFILE=./Gemfile bundle exec erector app/views/posts"

          FileUtils.rm_f("app/views/posts/*.erb")
          run "BUNDLE_GEMFILE=./Gemfile bundle exec rake --trace db:migrate"

          # run "script/server" # todo: launch in background; use mechanize or something to crawl it; then kill it
          # perhaps use open4?
          # open http://localhost:3000/posts
        end
      end
    end
  end
end
