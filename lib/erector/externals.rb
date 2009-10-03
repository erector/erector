module Erector
  module Externals
    module ClassMethods
      def externals(type, klass = nil)
        type = type.to_sym
        assure_externals_declared(type, klass)
        x = @@externals[type].dup
        if klass
          x.select{|value| @@externals[klass].include?(value)}
        else
          x
        end
      end

      def assure_externals_declared(type, klass)
        @@externals ||= {}
        @@externals[type] ||= []
        @@externals[klass] ||= [] if klass
      end

      def external(type, value)
        type = type.to_sym
        klass = self # since it's a class method, self should be the class itself
        assure_externals_declared(type, klass)
        @@externals[type] << value unless @@externals[type].include?(value)
        @@externals[klass] << value unless @@externals[klass].include?(value)
      end
    end
    
    def self.included(klass)
      klass.extend(ClassMethods)
    end
  end
end
