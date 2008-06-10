class SpecSuite
  class << self
    def all
      system("ruby #{dir}/core_spec_suite.rb") || raise("Core Spec Suite failed")
      dir = File.dirname(__FILE__)
      require "#{dir}/../lib/erector/rails/supported_rails_versions"
      versions = Erector::Rails::SUPPORTED_RAILS_VERSIONS.keys.sort.reverse
      versions.each do |rails_version|
        puts "Running rails_spec_suite for Rails version #{rails_version}"
          run_with_rails_version("#{dir}/rails_spec_suite.rb", rails_version) ||
            "Suite failed for Rails version #{rails_version}"
      end
    end

    def core
      run Dir["#{dir}/{erect,erector}/**/*_spec.rb"]
    end

    def rails
      Dir.chdir("#{dir}/rails/rails_root") do
        run Dir["spec/**/*_spec.rb"]
      end
    end

    def run(files)
      files.each do |file|
        require file
      end
    end

    protected
    def run_with_rails_version(suite_path, rails_version)
      system("export RAILS_VERSION=#{rails_version} && ruby #{suite_path}") ||
        raise("Failed for version #{rails_version}")
    end

    def dir
      File.dirname(__FILE__)
    end
  end
end

if $0 == __FILE__
  SpecSuite.all
end