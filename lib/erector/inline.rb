module Erector
  def self.inline(*args, &block)
    InlineWidget.new(*args, &block)
  end
  
  module Inline
    # Executes the widget's block (the one that was passed in the
    # constructor). Since "self" is pointing to the new widget, the block does
    # not naturally have access to parent method methods, so an
    # Erector::Inline widget uses some method_missing black magic to propagate
    # messages to the parent object. Since it executes inside the *called*
    # widget's context, when the block refers to instance variables, it's
    # talking about those of this widget, not the caller. It does, of course,
    # have access to bound local variables of the caller, so you can use those
    # to smuggle in instance variables.
    def call_block
      # note that instance_eval seems to pass in self as a parameter to the block
      instance_eval(&block) if block
    end
    
    private
    # This is part of the sub-widget/parent feature (see #widget method).
    def method_missing(name, *args, &block)
      if parent && parent.respond_to?(name)
        block ||= lambda {} # captures self HERE
        parent.send(name, *args, &block)
      else
        super
      end
    end
  end

  class InlineWidget < Erector::Widget
    include Inline
  end

end
