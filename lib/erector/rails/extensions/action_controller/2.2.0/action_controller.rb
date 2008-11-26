ActionController::Base.class_eval do
  def render_widget(widget_class, assigns=@assigns)
    @__widget_class = widget_class
    response.template.send(:_evaluate_assigns_and_ivars)
    render :inline => "<% @__widget_class.new(self, @assigns, StringIO.new(output_buffer)).render %>"
  end

  def render_with_erector_widget(*options, &block)
    if options.first.is_a?(Hash) && widget = options.first.delete(:widget)
      render_widget widget, @assigns, &block
    else
      render_without_erector_widget *options, &block
    end
  end
  alias_method_chain :render, :erector_widget
end
