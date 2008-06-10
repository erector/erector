unless ActionView.const_defined?(:Template)
  ActionView::Base.class_eval do
    attr_reader :template_file_path
    def render_template_with_saving_file_path(template_extension, template, file_path = nil, local_assigns = {})
      @template_file_path = file_path
      render_template_without_saving_file_path(template_extension, template, file_path, local_assigns)
    end
    alias_method_chain :render_template, :saving_file_path

    def render_partial_with_notification(*args, &blk)
      @is_partial_template = true
      render_partial_without_notification(*args, &blk)
    end
    alias_method_chain :render_partial, :notification

    def is_partial_template?
      @is_partial_template || false
    end
  end
end

