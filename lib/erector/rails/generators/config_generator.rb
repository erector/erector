require 'rails/generators'
module Erector
  module Rails
    module Generators
      class ConfigGenerator < ::Rails::Generators::Base
        source_root File.expand_path("../templates", __FILE__)

        desc "Adds Erector initializer to your application."

        def copy_initializer
          template "erector.rb", "config/initializers/erector.rb"
        end

      end
    end
  end
end