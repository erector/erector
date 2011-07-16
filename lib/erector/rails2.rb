require "action_controller"
require "erector/rails2/rails_version"
require "erector/rails2/rails_form_builder"
require "erector/rails2/extensions/action_controller"
require "erector/rails2/extensions/rails_helpers"
require "erector/rails2/extensions/rails_widget"
require "erector/rails2/template_handlers/rb_handler"
require "erector/rails2/template_handlers/ert_handler"

module Erector
  def self.init_rails(binding)
    # Rails defaults do not include app/views in the eager load path.
    # It needs to be there, because erector views are .rb files.
    if config = eval("config if defined? config", binding)
      view_path = config.view_path
      config.load_paths       << view_path unless config.load_paths.include?(view_path)
      config.eager_load_paths << view_path unless config.eager_load_paths.include?(view_path)

      # Rails probably already ran Initializer#set_load_path and
      # #set_autoload_paths by the time we got here.
      $LOAD_PATH.unshift(view_path) unless $LOAD_PATH.include?(view_path)
      unless ActiveSupport::Dependencies.load_paths.include?(view_path)
        ActiveSupport::Dependencies.load_paths << view_path
      end
    end
  end
end
