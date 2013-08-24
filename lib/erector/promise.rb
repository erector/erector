require "erector/attributes"
require "erector/text"

module Erector
  class Promise
    extend Attributes
    extend Text

    def initialize(output, tag_name, attributes = {}, self_closing = false, newliney = true, &inside_renderer)
      raise "bad output: #{output.inspect}" unless output.is_a? Output
      raise "forgot self-closing" unless [false, true].include? self_closing

      @output = output

      # todo: pointer to Tag object?
      @tag_name = tag_name
      @self_closing = self_closing
      @newliney = newliney

      @attributes = {}
      _set_attributes attributes
      @text = nil
      @inside_renderer = inside_renderer
      _mark
    end

    def _set_attributes attributes
      attributes.each_pair do |k,v|
        @attributes[k.to_s] = v
      end
    end

    def _mark
      @mark = @output.mark
    end

    def _rewind
      @output.rewind @mark
    end

    def _render
      _rewind
      _render_open_tag
      begin
        _render_inside_tag
      ensure
        _render_close_tag
      end
    end

    def _render_open_tag

      @output.newline if !@self_closing and @newliney and !@output.at_line_start?

      @output << RawString.new( "<#{@tag_name}#{Promise.format_attributes(@attributes)}")
      if @self_closing
        @output << RawString.new( " />")
        @output.newline if @newliney
      else
        @output << RawString.new( ">")
        @output.indent
      end
    end

    def _render_inside_tag
      return if @self_closing
      if @text
        @output << @text
      end
      if @inside_renderer
        @inside_renderer.call
      end
    end

    def _render_close_tag
      return if @self_closing

      @output.undent
      @output<< RawString.new("</#{@tag_name}>")
      if @newliney
        @output.newline
      end
    end

    def method_missing(method_name, *args, &block)
      method_name = method_name.to_s
      if Erector::Widget.hyphenize_underscores
        method_name = method_name.gsub(/_/, "-")
      end

      if method_name =~ /\!$/
        id_str = method_name[0...-1]
        raise ArgumentError, "setting id #{id_str} but id #{@attributes["id"]} already present" if @attributes["id"]
        @attributes["id"] = id_str
      else
        if @attributes["class"]
          @attributes["class"] += " "
        else
          @attributes["class"] = ""
        end
        @attributes["class"] += method_name.to_s
      end

      if block_given?
        @inside_renderer = block
      end

      if args.last.is_a? Hash
        attributes = args.pop
        _set_attributes attributes
      end

      # todo: allow multiple args
      # todo: allow promise args
      @text = args.first

      _render

      self
    end

    # are these accessors necessary?

    def _tag_name
      @tag_name
    end

    def _attributes
      @attributes
    end

    def _open_tag
      @open_tag
    end

    def _close_tag
      @close_tag
    end

  end
end
