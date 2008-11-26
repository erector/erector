dir = File.dirname(__FILE__)
if ActionView.const_defined?(:Template)
  if ActionView.const_defined?(:TemplateHandlers)
    require File.expand_path("#{dir}/2.2.0/action_view_template_handler")
  else
    require File.expand_path("#{dir}/2.0.0/action_view_template_handler")
  end
else
  require File.expand_path("#{dir}/1.2.5/action_view_template_handler")
end
