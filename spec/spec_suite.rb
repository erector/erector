class SpecSuite
  class << self
    def all
      system("ruby #{dir}/core_spec_suite.rb") || rails("Core Spec Suite failed")
    end

    def core
      run Dir["#{dir}/**/*_spec.rb"]
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