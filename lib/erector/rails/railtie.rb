module Erector
  class Railtie < ::Rails::Railtie
    # config.generators.template_engine :rb

    # TODO: automatically add app directory to app.config.autoload_paths,
    # so that Views::Foo::Bar autoloads, and 'require "views/foo/bar.html"'
    # works. For now, you must add the following to config/application.rb:
    #
    #     config.autoload_paths += %W(#{config.root}/app)
    #
    # (Maybe ::Rails.configuration.autoload_paths will work?)
  end
end
