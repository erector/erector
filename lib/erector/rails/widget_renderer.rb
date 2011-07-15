require 'action_controller/metal/renderers'

ActionController.add_renderer :widget do |widget, options|
  self.content_type ||= options[:content_type] || Mime[:html]
  Erector::Rails.render(widget, view_context, {}, false, options)
end
