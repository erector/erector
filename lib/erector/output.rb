module Erector
  class Output
    SPACES_PER_INDENT = 2

    attr_reader :prettyprint, :widgets, :indentation, :max_length

    def initialize(options = {}, & get_buffer)
      @prettyprint = options.fetch(:prettyprint, Widget.prettyprint_default)
      @indentation = options.fetch(:indentation, 0)
      @current_line_length = 0
      @max_length = options[:max_length]
      @widgets = []
      if get_buffer
        @get_buffer = get_buffer
      elsif buffer = options[:output]
        @get_buffer = lambda { buffer }
      else
        buffer = []
        @get_buffer = lambda { buffer }
      end
    end

    def buffer
      @get_buffer.call
    end

    def <<(s)
      s = s.to_s unless s.is_a? String
      append_indentation
      if @max_length && s.length + @current_line_length > @max_length
        need_space = false
        words = s.split(/ /)
        words.each do |word|
          if (need_space ? 1 : 0) + word.length > space_left
            append_newline
            append_indentation
            need_space = false
          end
          append(" ") if need_space
          append(word)
          need_space = true
        end
      else
        append(s)
      end
      self
    end

    def placeholder
      s = ""
      buffer << s
      s
    end

    def to_s
      RawString.new(buffer.to_s)
    end

    def to_a
      buffer.to_a
    end

    def newline
      if prettyprint
        append_newline
      end
    end

    def at_line_start?
      @current_line_length == 0
    end

    def indent
      @indentation += 1 if prettyprint
    end

    def undent
      @indentation -= 1 if prettyprint
    end

    protected

    def append_newline
      buffer << "\n"
      @current_line_length = 0
    end

    def append(s)
      buffer << s
      @current_line_length += s.length
    end

    def space_left
      @max_length - @current_line_length
    end

    def append_indentation
      if prettyprint and at_line_start?
        spaces = " " * ([@indentation, 0].max * SPACES_PER_INDENT)
        buffer << spaces
        @current_line_length += spaces.length
      end
    end

  end
end
