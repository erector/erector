module ActiveSupport
  module Dependencies

    def search_for_file(path_suffix)
      path_suffix = path_suffix.sub(/(\.rb)?$/, ".rb")
      underscored_path_suffix = path_suffix.gsub(/\/([\w\.]*$)/, '/_\1')

      autoload_paths.each do |root|
        path = File.join(root, path_suffix)
        return path if File.file? path
        upath = File.join(root, underscored_path_suffix)
        return upath if File.file? upath
      end
      nil # Gee, I sure wish we had first_match ;-)
    end

  end
end
