ActionController::Base.class_eval do
  def render_widget(widget_class, assigns=nil)
    unless assigns
      assigns = {}
      variables = instance_variable_names
      variables -= protected_instance_variables
      variables.each do |name|
        assigns[name.sub('@', "")] = instance_variable_get(name)
      end
    end
    response.template.send(:_evaluate_assigns_and_ivars)
    render :text => @template.with_output_buffer { widget_class.new(assigns.merge(:parent => @template)).to_s }
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
