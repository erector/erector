ActionController::Base.class_eval do
  def render_widget(widget_class, assigns=@assigns)
    @__widget_class = widget_class
    @__widget_assigns = assigns
    add_variables_to_assigns
    render :inline => "<% @__widget_class.new(self, @__widget_assigns, StringIO.new(_erbout)).render %>"
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
