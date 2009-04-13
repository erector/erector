##
# Erector view framework
module Erector
  if !Erector.const_defined?(:VERSION)
    dir = File.dirname(__FILE__)
    version = YAML.load_file(File.expand_path("#{dir}/../../VERSION.yml"))
    VERSION = "#{version[:major]}.#{version[:minor]}.#{version[:patch]}"
  end
end

