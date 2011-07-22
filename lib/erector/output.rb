require 'erector/abstract_widget'

module Erector
  class Output
    SPACES_PER_INDENT = 2

    attr_reader :prettyprint, :widgets, :indentation, :max_length

    def initialize(options = {})
      @prettyprint = options.fetch(:prettyprint, AbstractWidget.prettyprint_default)
      @indentation = options.fetch(:indentation, 0)
      @current_line_length = 0
      @max_length = options[:max_length]
      @widgets = []

      @get_buffer = if options[:buffer] and options[:buffer].respond_to? :call
        options[:buffer]
      elsif options[:buffer]
        lambda { options[:buffer] }
      else
        buffer = []
        lambda { buffer }
      end
    end

    def buffer
      @get_buffer.call
    end

    def <<(s)
      # raise s.inspect unless s.is_a? String
      #
      s = s.to_s unless s.is_a? String
      append_indentation
      if @max_length && s.length + @current_line_length > @max_length
        leading_spaces = s =~ /^( +)/ ? $1.size : 0
        trailing_spaces = s =~ /( +)$/ ? $1.size : 0

        append(" " * leading_spaces)
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
        append(" " * trailing_spaces)
      else
        append(s)
      end
      self
    end

    # Inserts a blank string into the output stream and returns a pointer to
    # it. If the caller holds on to this pointer, she can later go back and
    # insert text earlier in the stream. This is used for, e.g., inserting
    # stuff inside the HEAD element that is not known until after the entire
    # page renders.
    def placeholder
      s = ""
      buffer << s
      s
    end

    def to_s
      RawString.new(buffer.kind_of?(String) ? buffer : buffer.join)
    end

    def to_a
      buffer.kind_of?(Array) ? buffer : [buffer]
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

    # always append a newline, regardless of prettyprint setting
    #todo: test
    def append_newline
      buffer << "\n"
      @current_line_length = 0
    end

    def mark
      @mark = buffer.size
    end

    def rewind pos = @mark
      if buffer.kind_of?(Array)
        buffer.slice!(pos..-1)
      elsif (Object.const_defined?(:ActiveSupport) and
        buffer.kind_of?(ActiveSupport::SafeBuffer))
        # monkey patch to get around SafeBuffer's well-meaning paranoia
        # see http://yehudakatz.com/2010/02/01/safebuffers-and-rails-3-0/
        # and http://weblog.rubyonrails.org/2011/6/8/potential-xss-vulnerability-in-ruby-on-rails-applications
        String.instance_method(:slice!).bind(buffer).call(pos..-1)
      elsif buffer.kind_of?(String)
        buffer.slice!(pos..-1)
      else
        raise "Don't know how to rewind a #{buffer.class}"
      end

    end

    protected

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
