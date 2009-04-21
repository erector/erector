ActionController::Base.class_eval do
  def render_widget(widget_class, assigns=nil)
    @__widget_class = widget_class
    if assigns
      @__widget_assigns = assigns
    else
      @__widget_assigns = {}
      variables = instance_variable_names
      variables -= protected_instance_variables
      variables.each do |name|
        @__widget_assigns[name.sub('@', "")] = instance_variable_get(name)
      end
    end
    response.template.send(:_evaluate_assigns_and_ivars)
    render :inline => "<% @__widget_class.new(@__widget_assigns).to_s(:output => output_buffer, :helpers => self) %>"
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
