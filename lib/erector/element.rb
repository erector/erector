require 'erector/abstract_widget'
require 'erector/promise'

# todo: unit test
module Erector
  module Element
    # Internal method used to emit an HTML/XML element, including an open tag,
    # attributes (optional, via the default hash), contents (also optional),
    # and close tag.
    #
    # Using the arcane powers of Ruby, there are magic methods that call
    # +element+ for all the standard HTML tags, like +a+, +body+, +p+, and so
    # forth. Look at the source of erector/html.rb for the full list.
    # Unfortunately, this big mojo confuses rdoc, so we can't see each method
    # in this rdoc page, but trust us, they're there.
    #
    # When calling one of these magic methods, put attributes in the default
    # hash. If there is a string parameter, then it is used as the contents.
    # If there is a block, then it is executed (yielded), and the string
    # parameter is ignored. The block will usually be in the scope of the
    # child widget, which means it has access to all the methods of Widget,
    # which will eventually end up appending text to the +output+ string. See
    # how elegant it is? Not confusing at all if you don't think about it.
    #
    def element(*args, &block)
      _element(*args, &block)
    end

    # Internal method used to emit a self-closing HTML/XML element, including
    # a tag name and optional attributes (passed in via the default hash).
    #
    # Using the arcane powers of Ruby, there are magic methods that call
    # +empty_element+ for all the standard HTML tags, like +img+, +br+, and so
    # forth. Look at the source of #self_closing_tags for the full list.
    # Unfortunately, this big mojo confuses rdoc, so we can't see each method
    # in this rdoc page, but trust us, they're there.
    #
    def empty_element(*args, &block)
      _empty_element(*args, &block)
    end

    # moved to Promise
    # # Emits an open tag, comprising '<', tag name, optional attributes, and '>'
    # def open_tag(promise)
    #   output.newline if newliney?(promise._tag_name) && !output.at_line_start?
    #   output << promise._open_tag
    #   output.indent
    # end
    #
    # # Emits a close tag, consisting of '<', '/', tag name, and '>'
    # def close_tag(promise)
    #   output.undent
    #   output << promise._close_tag
    #   if newliney?(promise._tag_name)
    #     output.newline
    #   end
    # end
    #
    # def inside_tag value, block
    #   if block
    #     block.call
    #   else
    #     text value
    #   end
    # end

    def _element(tag_name, *args, &block)
      if args.length > 2
        raise ArgumentError, "too many args"
      end
      attributes, value = nil, nil
      arg0 = args[0]
      if arg0.is_a?(Hash)
        attributes = arg0
      else
        value = arg0
        arg1 = args[1]
        if arg1.is_a?(Hash)
          attributes = arg1
        end
      end

      if block && value
        raise ArgumentError, "You can't pass both a block and a value to #{tag_name} -- please choose one."
      end

      attributes ||= {}
      promise = if !value.nil?
        Promise.new(output, tag_name,  attributes, false, newliney?(tag_name)) do
          if value.is_a? AbstractWidget
            widget value
          else
            text value
          end
        end
      elsif block
        Promise.new(output, tag_name, attributes, false, newliney?(tag_name), &block)
      else
        Promise.new(output, tag_name, attributes, false, newliney?(tag_name))
      end
      promise._render
      promise
    end

    def _empty_element(tag_name, attributes={})
      promise = Promise.new(output, tag_name, attributes, true, newliney?(tag_name))
      promise._render
      promise
    end


  end
end
