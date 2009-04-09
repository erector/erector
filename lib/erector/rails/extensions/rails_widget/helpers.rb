module Erector
  class RailsWidget < Widget
    include ActionController::UrlWriter

    # helpers returning raw text
    [
      :image_tag,
      :javascript_include_tag,
      :stylesheet_link_tag,
      :sortable_element,
      :sortable_element_js,
      :text_field_with_auto_complete,
    ].each do |helper_name|
      define_method helper_name do |*args|
        begin
          text raw(helpers.send(helper_name, *args))
        rescue => e
          puts e.backtrace.join("\n\t")
          raise e
        end
      end
    end

    # helpers returning raw text whose first parameter is HTML escaped
    [
      :link_to,
      :link_to_remote,
      :mail_to,
      :button_to,
      :submit_tag,
    ].each do |helper_name|

      method_def =<<-METHOD_DEF
      def #{helper_name}(link_text, *args, &block)
        text raw(helpers.#{helper_name}(h(link_text), *args, &block))
      end
      METHOD_DEF
      eval(method_def)
    end

    def error_messages_for(*args)
      text raw(helpers.error_messages_for(*args))
    end

    # return text, take block
    [
      :link_to_function,
      :text_field_tag,
      :password_field_tag,
      :check_box_tag
    ].each do |method_to_proxy_with_block|
      method_def =<<-METHOD_DEF
      def #{method_to_proxy_with_block}(*args, &block)
        text raw(helpers.#{method_to_proxy_with_block}(*args, &block))
      end
      METHOD_DEF
      eval(method_def)
    end

    # render text, take block
    [
      :error_messages_for,
      :form_tag,
      :form_for,
    ].each do |method_to_proxy_with_block|
      method_def =<<-METHOD_DEF
      def #{method_to_proxy_with_block}(*args, &block)
        helpers.#{method_to_proxy_with_block}(*args, &block)
      end
      METHOD_DEF
      eval(method_def)
    end

    def javascript_include_merged(key)
      helpers.javascript_include_merged(key)
    end

    def stylesheet_link_merged(key)
      helpers.stylesheet_link_merged(key)
    end

    def flash
      helpers.controller.send(:flash)
    end

    def session
      helpers.controller.session
    end

    def controller
      helpers.controller
    end

    def cycle(*args)
      helpers.cycle(*args)
    end

    def simple_format(string)
      p raw(string.to_s.html_escape.gsub(/\r\n?/, "\n").gsub(/\n/, "<br/>\n"))
    end

    def time_ago_in_words(*args)
      helpers.time_ago_in_words(*args)
    end

    def pluralize(*args)
      helpers.pluralize(*args)
    end
  end
end
