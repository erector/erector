module Erector
  module Helpers

    [
        :image_tag,
        :javascript_include_tag,
        :stylesheet_link_tag,
        :sortable_element,
        :sortable_element_js
    ].each do |helper_name|
      define_method helper_name do |*args|
        text raw(helpers.send(helper_name, *args))
      end
    end

    [
        :link_to_function,
        :link_to,
        :link_to_remote,
        :mail_to
    ].each do |link_helper|
      define_method link_helper do |link_text, *args|
        text raw(helpers.send(link_helper, h(link_text), *args))
      end
    end

    def error_messages_for(*args)
      fake_erbout do
        helpers.error_messages_for(*args)
      end
    end

    def form_for(*args, &block)
      fake_erbout do
        helpers.form_for(*args, &block)
      end
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