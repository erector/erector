module ControllerSpecHelper

  class ::TestApplicationController < ActionController::Base
    # Let exceptions propagate rather than generating the usual error page.
    include ActionController::TestCase::RaiseActionExceptions

    # replicate deprecated use for rails <3.2
    if (Gem::Version.new(Rails.version) < Gem::Version.new('3.2.0') rescue true)
      def render(*args, &block)
        options = args.extract_options!
        if options[:template]
          handlers = options.delete(:handlers)
          format = '.html' unless options.delete(:bare)
          options[:template] += "#{format}.#{handlers.first}"
        end
        render(*(args << options), &block)
      end
    end

    def self.with_action(name = :default, &block)
      define_method(name.to_sym) do
        instance_eval(&block) if block
      end
    end

    def with_ignoring_extra_controller_assigns(klass, value)
      old_value = klass.ignore_extra_controller_assigns
      begin
        klass.ignore_extra_controller_assigns = value
        yield
      ensure
        klass.ignore_extra_controller_assigns = old_value
      end
    end

    def with_controller_assigns_propagate_to_partials(klass, value)
      old_value = klass.controller_assigns_propagate_to_partials
      begin
        klass.controller_assigns_propagate_to_partials = value
        yield
      ensure
        klass.controller_assigns_propagate_to_partials = old_value
      end
    end

  end

  def test_controller(const = 'TestController')
    new_class = Class.new(TestApplicationController) do
      yield if block_given?
    end
    Object.send(:remove_const, const) if Object.const_defined?(const)
    Object.const_set(const, new_class)
  end

end