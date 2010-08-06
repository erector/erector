require "erector/rails/rails_form_builder"
require "erector/rails/rails_widget_renderer"
require "erector/rails/rails_helpers"
require "erector/rails/rails_widget"
require "erector/rails/template_handlers/rb_handler"
require "erector/rails/template_handlers/ert_handler"

module Erector
  class Railtie < ::Rails::Railtie
    config.generators.template_engine :erector

    # TODO: automatically add app directory to app.config.autoload_paths,
    # so that Views::Foo::Bar autoloads, and 'require "views/foo/bar.html"'
    # works. For now, you must add the following to config/application.rb:
    #
    #     config.autoload_paths += %W(#{config.root}/app)
  end
end
