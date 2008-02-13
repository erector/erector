module Erector
  module Helpers
    [
        :link_to,
        :image_tag,
        :javascript_include_tag,
        :stylesheet_link_tag,
        :link_to_function,
        :link_to_remote,
        :sortable_element,
        :sortable_element_js,
        :mail_to
    ].each do |helper_name|
      define_method helper_name do |*args|
        text helpers.send(helper_name, *args)
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

    def simple_format(*args)
      helpers.simple_format(*args)
    end

    def time_ago_in_words(*args)
      helpers.time_ago_in_words(*args)
    end

    def pluralize(*args)
      helpers.pluralize(*args)
    end
  end
end