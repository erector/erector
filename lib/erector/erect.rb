require "optparse"
require "rake"
require "erector/erected"  # pull this out so we don't recreate the grammar every time

module Erector
  class Erect
    attr_reader :files, :verbose, :mode, :output_dir
    def initialize(args)
      @verbose = true
      @mode = :to_erector
      @output_dir = nil
      
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: erector [options] [file|dir]*"

        opts.separator "Converts from html/rhtml files to erector widgets, or from erector widgets to html files"
        opts.separator ""
        opts.separator "Options:"

        opts.on("-q", "--quiet",
                "Operate silently except in case of error") do |quiet|
          @verbose = !quiet
        end
        
        opts.on("--to-erector", "(default) Convert from html/rhtml to erector classes") do
          @mode = :to_erector
        end

        opts.on("--to-html", "Convert from erector to html") do
          @mode = :to_html
        end
        
        opts.on("-o", "--output-dir DIRECTORY", "Output files to DIRECTORY (default: output files go next to input files)") do |dir|
          @output_dir = dir
        end

        opts.on_tail("-h", "--help", "Show this message") do
          @mode = :help
          puts opts
          exit
        end

        opts.on_tail("-v", "--version", "Show version") do
          puts Erector::VERSION
          exit
        end
        
      end
      opts.parse!(args)
      @files = args
      explode_dirs
    end
    
    def say(msg)
      print msg if verbose
    end
    
    #todo: unit test
    def explode_dirs
      exploded_files = FileList.new
      files.each do |file|
        if File.directory?(file)
          exploded_files.add(explode(file))
        else
          exploded_files.add(file)
        end
      end
      @files = exploded_files
    end
    
    def explode(dir)
      case mode
      when :to_erector
        FileList["#{dir}/**/*.rhtml", "#{dir}/**/*.html", "#{dir}/**/*.html.erb"]
      when :to_html
        FileList["#{dir}/**/*.rb"]
      end
    end
    
    def run
      @success = true
      self.send(mode)
      @success
    end
    
    def to_erector
      files.each do |file|
        say "Erecting #{file}... "
        begin
          e = Erector::Erected.new(file)
          e.convert
          say " --> #{e.filename}\n"
        rescue => e
          puts e
          puts e.backtrace.join("\n\t")
          @success = false
        end
      end
    end

    def to_html
      files.each do |file|
        say "Erecting #{file}... "
        #todo: move this into Erected with better tests for the naming methods
        begin
          #todo: fail if file isn't a .rb file
          require file
          filename = file.split('/').last.gsub(/\.rb$/, '')
          widget_name = camelize(filename)
          widget_class = constantize(widget_name)
          
          if widget_class < Erector::Widget
            widget = widget_class.new
            #todo: skip if it's missing a no-arg constructor
            dir = output_dir || File.dirname(file)
            FileUtils.mkdir_p(dir)
            output_file = "#{dir}/#{filename}.html"
            File.open(output_file, "w") do |f|
              f.puts widget.to_s
            end
            say " --> #{output_file}\n"
          else
            say " -- not a widget, skipping\n"
          end
        rescue => e
          puts e
          puts e.backtrace.join("\n\t")
          @success = false
        end
      end
    end
    
    # stolen from activesuppport/lib/inflector.rb
    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      if first_letter_in_uppercase
        lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      else
        lower_case_and_underscored_word.first + camelize(lower_case_and_underscored_word)[1..-1]
      end
    end
    def constantize(camel_cased_word)
      unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
        raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
      end
      Object.module_eval("::#{$1}", __FILE__, __LINE__)
    end
    

  end
end
