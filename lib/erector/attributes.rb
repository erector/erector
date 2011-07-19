module Erector
  module Attributes
    def format_attributes(attributes)
      if !attributes || attributes.empty?
        ""
      else
        format_sorted(sort_attributes(attributes))
      end
    end

    def format_sorted(sorted)
      results = ['']
      sorted.each do |key, value|
        if value
          if value.is_a?(Array)
            value = value.flatten
            next if value.empty?
            value = value.join(' ')
          end
          results << "#{key}=\"#{h(value)}\""
        end
      end
      results.join(' ')
    end

    def sort_attributes(attributes)
      stringized = []
      attributes.each do |key, value|
        stringized << [key.to_s, value]
      end
      stringized.sort
    end
  end
end
