module ActionView #:nodoc:
  module TemplateHandlers #:nodoc:
    class ErtTemplate < TemplateHandler
      include Compilable
      def self.line_offset
        2
      end

      ActionView::Template.instance_eval do
        register_template_handler :ert, ActionView::TemplateHandlers::ErtTemplate
      end

      def compile(template)
        [
          "extend ::Erector::Mixin",
          "@output_buffer = ''",
          "memoized_instance_variables = instance_variables.inject({}) do |all, instance_variable|",
          "  all[instance_variable] = instance_variable_get(instance_variable)",
          "  all",
          "end",
          "r = (controller.ert_template_base_class || ::Erector).inline do",
          "  memoized_instance_variables.each do |instance_variable, value|",
          "    instance_variable_set(instance_variable, value)",
          "  end",
          template.source,
          "end",
          "r.to_s",
        ].join("; ")
      end
    end
  end
end
