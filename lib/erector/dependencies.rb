module Erector
  class Dependencies < Array
    def push(*new_dependencies_args)
      new_dependencies = new_dependencies_args.select do |new_dependency|
        !include?(new_dependency)
      end
      new_dependencies.each do |dep|
        unless dep.is_a? Erector::Dependency
          raise "expected Dependency, got #{dep.class}: #{dep.inspect}"
        end
      end
      super(*new_dependencies)
    end

    alias_method :<<, :push

    def uniq
      inject(self.class.new) do |memo, item|
        memo << item unless memo.any? {|memo_item| memo_item == item}
        memo
      end
    end
  end
end
