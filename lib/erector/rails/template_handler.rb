module Erector
  module Rails

    class TemplateHandler
      def call(template)
        <<-SRC
        Erector::Rails.render(#{widget_class(template)}, self, local_assigns, #{partial?(template)})
        SRC
      end

      # if a template is partial is stored in the Path instance details[:virtual_path]
      # irrespective of how the file is named
      def partial?(template)
        !!template.virtual_path.partial? rescue false
      end

      # retrieves the erector widget class name
      # if template was found with a widget library resolver then library class prefix is attached
      # if template was found with default file system resolver then global widget_class_prefix is used (default to view)
      # loads the widget class if needed
      # checks if the class is defined, if not raises Erector::Rails::TemplateError
      def widget_class(template)
        require_dependency template.identifier
        virtual_path = template.virtual_path
        ::Rails.logger.warn "path = #{virtual_path.class.inspect}"
        virtual_path      = if virtual_path.respond_to?(:virtual_class_path)
                              virtual_path.virtual_class_path
                            else
                              File.join(Erector.widget_class_prefix.to_s.underscore, virtual_path)
                            end
        widget_class_name = virtual_path.camelize
        begin
          widget_class_name.constantize
        rescue NameError
          raise(::ArgumentError, "view template '#{template.identifier}' expected to define widget class #{widget_class_name}")
        end
        widget_class_name
      end

    end

    # given render 'prefix/name' this resolver will correctly find '/path/to/widgets/prefix/name.html.rb'
    # and the template handler expects it to define class 'virtual/class_prefix/prefix/name'
    #
    # if the virtual class prefix is nil, global default Erector.widget_class_prefix is used.
    # this is identical behaviour to using the default resolver given by a path string as view_path
    # except for partial names :TODO:
    #
    # In order to use these custom resolvers in a Rails application,
    # you just need to configure ActionController::Base.view_paths in an initializer
    # OR append_view_path
    # if you write a simple erector widget library with controller/action templates you can use this hook
    #
    # ActiveSupport.on_load(:action_controller) do
    #    append_view_path(WidgetLibraryResolver.new('virtual/class_prefix', '/path/to/widgets'))
    # end
    class WidgetLibraryResolver < ::ActionView::FileSystemResolver

      attr_accessor :class_prefix

      #DEFAULT_PATTERN = ":prefix/:action{.:locale,}{.:formats,}{.:handlers,}"
      #':action{.:locale,}{.:formats,}.rb'
      def initialize(class_prefix, path, pattern = nil)
        super(path, pattern)
        self.class_prefix = class_prefix || Erector.widget_class_prefix
      end

      def find_templates(name, prefix, partial, details)
        path = WidgetPath.build(name, filter_prefix(prefix), partial, class_prefix)
        query(path, details, details[:formats])
      end

      def filter_prefix(prefix)
        prefix
      end

    end

    # if you write a simple erector widget library with only action templates you can use this
    # by default or per controller
    # NOTE: since it disregards controller information, you should only use this resolver as
    # a fallback after your default view path resolvers (using # append_view_path)
    # ActiveSupport.on_load(:action_controller) do
    #    append_view_path(ActionWidgetLibraryResolver.new('virtual_class_prefix', '/path/to/widgets'))
    # end
    class ActionWidgetLibraryResolver < WidgetLibraryResolver

      def filter_prefix(prefix)
        ''
      end
    end

    class WidgetPath < ::ActionView::Resolver::Path

      attr_writer :virtual
      attr_accessor :virtual_class_path

      def self.build(name, prefix, partial, class_prefix)
        path                    = super(name, prefix, partial)
        # widgets should not use _ prefix in the virtual path used to map to class
        path_prefix = class_prefix.to_s.underscore
        path_prefix = File.join(path_prefix, prefix) unless prefix.nil? || prefix.empty?
        path.virtual_class_path = ::ActionView::Resolver::Path.build(name, path_prefix, false)
        path.virtual            = path
        path
      end

    end

  end
end

ActionView::Template.register_template_handler :rb, Erector::Rails::TemplateHandler.new
