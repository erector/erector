class ActionController::Base
  def render_widget(widget_class, assigns=@assigns)
    render :text => render_widget_to_string(widget_class, assigns)
  end

  def render_widget_to_string(widget_class, assigns = @assigns)
    add_variables_to_assigns
    @rendered_widget = widget_class.new(@template, assigns.merge(:params => params))
    @rendered_widget.to_s
  end

  attr_reader :rendered_widget
end