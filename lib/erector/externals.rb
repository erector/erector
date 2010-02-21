module Erector
  class External < Struct.new(:type, :text, :options)
    def initialize(type, text, options = {})
      text = text.read if text.is_a? IO
      text = External.interpolate(text) if options[:interpolate] # todo: test
      super(type.to_sym, text, options)
    end
    
    def self.interpolate(s)
      eval("<<INTERPOLATE\n" + s + "\nINTERPOLATE").chomp
    end
    
    def ==(other)
      (self.type == other.type and
      self.text == other.text and
      self.options == other.options) ? true : false
    end
  end

  module Externals
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def external(type, value, options = {})
        @externals ||= []
        type = type.to_sym
        x = External.new(type, value, options)
        @externals << x unless @externals.include?(x)
      end

      # returns all externals of the given type from this class and all its
      # superclasses
      def externals(type)
        @externals ||= []

        type = type.to_sym
        parent_externals = if superclass.respond_to?(:externals)
          superclass.externals(type)
        else
          []
        end

        my_externals = @externals.select do |external|
          external.type == type
        end

        (parent_externals + my_externals).uniq
      end
    end

    def render_with_externals(options_to_external_renderer = {})
      output = Erector::Output.new
      self.to_s(:output => output)
      nested_widgets = output.widgets.to_a
      externals = ExternalRenderer.new({:classes => nested_widgets}.merge(options_to_external_renderer)).to_s(:output => output)
      output.to_a
    end

    def render_externals(options_to_external_renderer = {})
      output_for_externals = Erector::Output.new
      nested_widgets = output.widgets
      externalizer = ExternalRenderer.new({:classes => nested_widgets}.merge(options_to_external_renderer))
      externalizer._render(:output => output_for_externals)
      output_for_externals.to_a
    end
  end
end
