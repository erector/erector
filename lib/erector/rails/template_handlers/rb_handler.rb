module Erector
  class RbHandler < ActionView::TemplateHandler
    def render(template, local_assigns)
      require_dependency File.expand_path(template.filename)
      widget_class = "views/#{template.path_without_format_and_extension}".camelize.constantize
      Erector::Rails.render(widget_class, @view.controller)
    end
  end
end

ActionView::Template.register_template_handler :rb, Erector::RbHandler
