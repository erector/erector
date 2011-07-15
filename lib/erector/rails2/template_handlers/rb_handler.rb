class ActionView::Base
  def instance_variables_for_widget_assignment
    instance_variables_for_widget_assignment_for(controller)
  end

  def instance_variables_for_widget_assignment_for(target)
    assigns = { }
    variables = target.instance_variable_names
    variables -= target.protected_instance_variables if target.respond_to?(:protected_instance_variables)
    variables -= %w{@real_format @request @template @_request}
    variables.each do |name|
      assign = name.sub('@', '').to_sym
      assigns[assign] = target.instance_variable_get(name)
    end
    assigns
  end
end

# Out of the box, the Cells plugin for Rails (http://cells.rubyforge.org/)
# does not work with Erector, because Erector tries to grab instance variables
# off the controller, rather than the cell itself.
#
# This code patches up Cell::View to make it work, but only if the Cells plugin
# is installed. (That's the bare "Cell::View" at the top, and rescue NameError
# at the bottom.) While you'd imagine that unilaterally opening Cell::View
# and adding the method would work, it doesn't; Cell::View is normally
# autoloaded, and since we'd end up defining it here, we'd keep it from getting
# loaded at all.
begin
  Cell::View

  class Cell::View < ActionView::Base
    def instance_variables_for_widget_assignment
      instance_variables_for_widget_assignment_for(cell)
    end
  end
rescue NameError, ArgumentError
end

module Erector
  class RbHandler < ActionView::TemplateHandler
    def render(template, local_assigns)
      require_dependency File.expand_path(template.filename)
      widget_class = "views/#{template.path_without_format_and_extension}".camelize.constantize
      is_partial = (File.basename(template.path_without_format_and_extension) =~ /^_/)
      assigns = Erector::Rails.assigns_for(widget_class, @view, local_assigns, is_partial)
      Erector::Rails.render(widget_class, @view, assigns)
    end
  end
end

ActionView::Template.register_template_handler :rb, Erector::RbHandler
