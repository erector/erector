ActionView::Base.class_eval do
  def render_partial_with_notification(*args, &blk)
    @is_partial_template = true
    render_partial_without_notification(*args, &blk)
  end
  alias_method_chain :render_partial, :notification

  def is_partial_template?
    @is_partial_template || false
  end
end
