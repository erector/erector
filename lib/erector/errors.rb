module Erector
  module Errors
    class RubyVersionNotSupported < RuntimeError
      def initialize(version_identifier, explanation=nil)
        super [
          "Erector does not support Ruby version(s) #{version_identifier}.",
          explanation ? "The reason(s) are:\n#{explanation}" : nil
        ].compact.join("\n")
      end
    end
  end
end