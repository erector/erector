module Erector
  module Rails
    class TemplateHandler < ActionView::Template::Handler
      def self.call(template)
        require_dependency template.identifier
        widget_class_name = "views/#{template.identifier =~ %r(views/([^.]*)(\..*)?\.rb) && $1}".camelize
        is_partial = File.basename(template.identifier) =~ /^_/
        <<-SRC
        Erector::Rails.render(#{widget_class_name}, self, local_assigns, #{!!is_partial})
        SRC
      end
    end
  end
end

ActionView::Template.register_template_handler :rb, Erector::Rails::TemplateHandler
