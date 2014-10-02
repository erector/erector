module Erector
  class Railtie < ::Rails::Railtie
    initializer 'erector.autoload', before: :set_autoload_paths do |app|
      app.config.autoload_paths << "#{::Rails.root}/app"
    end

    initializer 'erector.dependency_tracker' do
      ActiveSupport.on_load(:action_view) do
        ActiveSupport.on_load(:after_initialize) do
          begin
            require 'action_view/dependency_tracker'
            ActionView::DependencyTracker.register_tracker :rb, ActionView::DependencyTracker::ERBTracker
          rescue LoadError
            # likely this version of Rails doesn't support dependency tracking
          end
        end
      end
    end
  end
end
