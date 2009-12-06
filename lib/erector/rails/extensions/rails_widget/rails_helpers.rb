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
            s = parent.#{method_name}(*args, &block)
            puts "hi: \#{s}"
            puts output.inspect
            puts @output.inspect
            rawtext s
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
            wrapped_block = lambda do
              # the block is going to do erector stuff, so capture it and return it
              b = ''
              with_output_buffer(b) do
                block.call
              end
              puts "b=\#{b}"
              return b
            end
            
            captured = ''
            captured = parent.with_output_buffer(captured) do
              x = parent.#{method_name}(*args, &wrapped_block)
              puts "x=\#{x}"
              parent.output_buffer.to_s
            end
            puts "captured: \#{captured}"
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
      
      DIRECTLY_DELEGATED = [
        :url_for,
        :javascript_include_merged,
        :stylesheet_link_merged,
        :controller,
        :cycle,
        :time_ago_in_words,
        :pluralize,
        :image_path
      ]
      
      DIRECTLY_DELEGATED.each do |method_name|
        start_line = __LINE__ + 2
        method_def =<<-METHOD_DEF
          def #{method_name}(*args, &block)
            parent.#{method_name}(*args, &block)
          end
        METHOD_DEF
        eval(method_def, binding, __FILE__, start_line)
      end
      
      def flash
        parent.controller.send(:flash)
      end

      def session
        parent.controller.session
      end

      def simple_format(string)
        p raw(string.to_s.html_escape.gsub(/\r\n?/, "\n").gsub(/\n/, "<br/>\n"))
      end
    end

    Erector::Widget.send :include, Helpers
  end
end
