# Note that this class is only used in building erector itself
# (and even then, only needs to be run when there is a new
# UnicodeData.txt file from unicode.org).
class Erector::UnicodeBuilder

  def initialize(input, output)
    @input = input
    @output = output
    @first = true
  end
  
  def generate()
    @output.puts "Erector::CHARACTERS = {"
    process_file
    @output.puts "}"
  end

  def process_file()
    while !@input.eof
      line = @input.gets.strip
      if (line == "")
        next;
      end
      
      process_line(line)
    end
    if (!@first)
      @output.puts
    end
  end
  
  def output_line(line)
    if (!@first)
      @output.puts(',')
    end
    
    @output.print(line)

    @first = false
  end
  
  def process_line(line)
    fields = line.split(';')
    code_point = fields[0]
    name = fields[1]
    alternate_name = fields[10]

    if /^</.match(name)
      return ""
    end

    output name, code_point
    if (!alternate_name.nil? && alternate_name != "")
      output alternate_name, code_point
    end
  end
  
  def output(name, code_point)
    output_line "  :#{namify(name)} => 0x#{code_point.downcase}"
  end
  
  def namify(name)
    name.downcase.gsub(/[- ]/, '_')
  end

end

