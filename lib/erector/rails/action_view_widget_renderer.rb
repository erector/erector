# https://groups.google.com/group/erector/browse_thread/thread/6297c26343f80c49?hl=en
ActionView::Base.class_eval do
  def render_with_erector_widget(options = {}, locals = {}, &block)
    if widget = options.delete(:widget)
      options[:text] = Erector::Rails.render(widget, self, locals, false, options)
      puts options.inspect
    end
    options.delete :content_method_name
    render_without_erector_widget(options, locals, &block).html_safe
  end
  alias_method_chain :render, :erector_widget
end

