module Erector
  module Attributes
    def format_attributes(attributes)
      return "" if !attributes || attributes.empty?

      results = ['']

      attributes.each do |key, value|
        if value
          if value.is_a?(Array)
            value = value.flatten
            next if value.empty?
            value = value.join(' ')
          end

          if value.is_a?(TrueClass)
            results << "#{key}"
          elsif value.nil? || value.is_a?(FalseClass)
            # Nothing is generated in this case
          else
            results << "#{key}=\"#{h(value)}\""
          end
        end
      end

      results.join(' ')
    end
  end
end
