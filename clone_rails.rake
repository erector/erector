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
