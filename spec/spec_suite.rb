class SpecSuite
  class << self
    def all
      system("ruby #{dir}/core_spec_suite.rb") || raise("Core Spec Suite failed")

      require "#{dir}/../lib/erector/rails/rails_version"

      rails_version = Erector::Rails::RAILS_VERSION
      puts "Running rails_spec_suite for Rails version #{rails_version}"

      system("ruby #{dir}/rails_spec_suite.rb") || raise("Failed for version #{rails_version}")
    end

    def core
      run Dir["#{dir}/{erect,erector}/**/*_spec.rb"] - ["#{dir}/erect/erect_rails_spec.rb"]
    end

    def rails
      run ["#{dir}/erect/erect_rails_spec.rb"]
      Dir.chdir("#{dir}/rails_root") do
        run Dir["spec/**/*_spec.rb"]
      end
    end

    def run(files)
      files.each do |file|
        require file
      end
    end

    protected
    def dir
      File.dirname(__FILE__)
    end
  end
end

if $0 == __FILE__
  SpecSuite.all
end
