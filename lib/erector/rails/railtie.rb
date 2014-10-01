module Erector
  class Railtie < ::Rails::Railtie
    initializer 'erector.autoload', before: :set_autoload_paths do |app|
      app.config.autoload_paths << "#{::Rails.root}/app"
    end
  end
end
