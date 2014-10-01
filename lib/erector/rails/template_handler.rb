module Erector
  module Rails
    class TemplateHandler
      def call(template)
        require_dependency template.identifier
        pathname = "#{template.identifier =~ %r(views/(.*)) && $1}"
        widget_class_name = "views/#{template.identifier =~ %r(views/([^.]*)(\..*)?\.rb) && $1}".camelize
        is_partial = File.basename(template.identifier) =~ /^_/
        <<-SRC
        Erector::Rails.render(#{widget_class_name}, self, local_assigns, #{!!is_partial}, pathname: "#{pathname}")
        SRC
      end
    end
  end
end

ActionView::Template.register_template_handler :rb, Erector::Rails::TemplateHandler.new
