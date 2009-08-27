module Erector
  class Inline < Erector::Widget
    # Evaluates its block (the one that was passed in the constructor) as a new widget's
    # content method.
    # Since "self" is pointing to the new widget, it can get access
    # to parent widget methods via method_missing. Since it executes inside the 
    # widget it does not
    # have access to instance variables of the caller, although it does
    # have access to bound variables.
    def content
      if @block
        instance_eval(&@block)
      end
    end
    
    private
    # This is part of the sub-widget/parent feature (see #widget method).
    def method_missing(name, *args, &block)
      block ||= lambda {} # captures self HERE
      if @parent
        @parent.send(name, *args, &block)
      else
        super
      end
    end

    
  end
end
