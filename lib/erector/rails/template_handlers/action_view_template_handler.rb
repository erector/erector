dir = File.dirname(__FILE__)
if ActionView.const_defined?(:TemplateHandlers)
  if ::ActionView::TemplateHandlers::const_defined?(:Compilable)
    if ActionView.const_defined?(:TemplateHandlers) && ::ActionView::TemplateHandlers::ERB.respond_to?(:erb_trim_mode)
      require File.expand_path("#{dir}/2.2.0/action_view_template_handler")
    else
      require File.expand_path("#{dir}/2.1.0/action_view_template_handler")
    end
  else
    require File.expand_path("#{dir}/2.0.0/action_view_template_handler")
  end
else
  require File.expand_path("#{dir}/1.2.5/action_view_template_handler")
end
