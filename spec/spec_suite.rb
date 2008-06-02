class SpecSuite
  class << self
    def all
      system("ruby #{dir}/core_spec_suite.rb") || raise("Core Spec Suite failed")
      system("ruby #{dir}/rails_spec_suite.rb") || raise("Rails Spec Suite failed")
    end

    def core
      run Dir["#{dir}/{erect,erector}/**/*_spec.rb"]
    end

    def rails
      run Dir["#{dir}/rails/**/*_spec.rb"]
    end

    def run(files)
      files.each do |file|
        require file
      end
    end

    def dir
      File.dirname(__FILE__)
    end
  end
end

if $0 == __FILE__
  SpecSuite.all
end