module Erector
  module Rails
    module Helpers
      include ActionController::UrlWriter

      # parent returning raw text whose first parameter is HTML escaped
      ESCAPED_HELPERS = [
        :link_to,
        :link_to_remote,
        :mail_to,
        :button_to,
        :submit_tag,
      ]
      ESCAPED_HELPERS.each do |method_name|
        start_line = __LINE__ + 2
        method_def =<<-METHOD_DEF
          def #{method_name}(link_text, *args, &block)
            rawtext(parent.#{method_name}(h(link_text), *args, &block))
          end
        METHOD_DEF
        eval(method_def, binding, __FILE__, start_line)
      end

      # return text, take block
      RAW_HELPERS = [
        :link_to_function,
        :text_field_tag,
        :password_field_tag,
        :check_box_tag,
        :error_messages_for,
        :submit_tag,
        :file_field,
        :image_tag,
        :javascript_include_tag,
        :stylesheet_link_tag,
        :sortable_element,
        :sortable_element_js,
        :text_field_with_auto_complete
      ]
      RAW_HELPERS.each do |method_name|
        start_line = __LINE__ + 2
        method_def =<<-METHOD_DEF
          def #{method_name}(*args, &block)
            rawtext parent.#{method_name}(*args, &block)
          end
        METHOD_DEF
        eval(method_def, binding, __FILE__, start_line)
      end

      CAPTURED_HELPERS_WITHOUT_CONCAT = [
        :render
      ]
      CAPTURED_HELPERS_WITHOUT_CONCAT.each do |method_name|
        start_line = __LINE__ + 2
        method_def =<<-METHOD_DEF
          def #{method_name}(*args, &block)
            captured = parent.capture do
              parent.concat(parent.#{method_name}(*args, &block))
              parent.output_buffer.to_s
            end
            rawtext(captured)
          end
        METHOD_DEF
        eval(method_def, binding, __FILE__, start_line)
      end

      CAPTURED_HELPERS_WITH_CONCAT = [
        :form_tag
      ]
      CAPTURED_HELPERS_WITH_CONCAT.each do |method_name|
        start_line = __LINE__ + 2
        method_def =<<-METHOD_DEF
          def #{method_name}(*args, &block)
            captured = parent.capture do
              parent.#{method_name}(*args, &block)
              parent.output_buffer.to_s
            end
            rawtext(captured)
          end
        METHOD_DEF
        eval(method_def, binding, __FILE__, start_line)
      end

      def form_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        options[:builder] ||= ::Erector::RailsFormBuilder
        args.push(options)
        parent.form_for(record_or_name_or_array, *args, &proc)
      end

      def fields_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        options[:builder] ||= ::Erector::RailsFormBuilder
        args.push(options)
        parent.fields_for(record_or_name_or_array, *args, &proc)
      end

      def javascript_include_merged(key)
        parent.javascript_include_merged(key)
      end

      def stylesheet_link_merged(key)
        parent.stylesheet_link_merged(key)
      end

      def flash
        parent.controller.send(:flash)
      end

      def session
        parent.controller.session
      end

      def controller
        parent.controller
      end

      def cycle(*args)
        parent.cycle(*args)
      end

      def simple_format(string)
        p raw(string.to_s.html_escape.gsub(/\r\n?/, "\n").gsub(/\n/, "<br/>\n"))
      end

      def time_ago_in_words(*args)
        parent.time_ago_in_words(*args)
      end

      def pluralize(*args)
        parent.pluralize(*args)
      end
    end

    Erector::Widget.send :include, Helpers
  end
end
