require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require File.expand_path("#{File.dirname(__FILE__)}/../../lib/erector/unicode_builder")

describe "build unicode" do

  def make_builder(input_string)
    @output = ""
    Erector::UnicodeBuilder.new(
      StringIO.new(input_string), 
      StringIO.new(@output))
  end

  it "#generate generates header and footer" do
    make_builder("").generate()
    @output.should == "Erector::CHARACTERS = {\n}\n"
  end

  it "generates nothing from empty file" do
    make_builder("").process_file()
    @output.should == ""
  end
  
  it "generates nothing from blank line" do
    make_builder("\n").process_file()
    @output.should == ""
  end
  
  it "generates entry from a simple line" do
    make_builder(%q{
0025;PERCENT SIGN;Po;0;ET;;;;;N;;;;;
    }).process_file()
    @output.should == "  :percent_sign => 0x0025\n"
  end
  
  it "can process two lines" do
    make_builder(%q{
0906;DEVANAGARI LETTER AA;Lo;0;L;;;;;N;;;;;
237E;BELL SYMBOL;So;0;ON;;;;;N;;;;;
    }).process_file()
    @output.should == "  :devanagari_letter_aa => 0x0906,\n" +
      "  :bell_symbol => 0x237e\n"
  end
  
  it "also adds an entry for an alias" do
    make_builder(%q{
2192;RIGHTWARDS ARROW;Sm;0;ON;;;;;N;RIGHT ARROW;;;;
    }).process_file()
    @output.should == "  :rightwards_arrow => 0x2192,\n" +
      "  :right_arrow => 0x2192\n"
  end
  
  it "can handle hyphen in name" do
    make_builder(%q{
2673;RECYCLING SYMBOL FOR TYPE-1 PLASTICS;So;0;ON;;;;;N;;pete;;;
    }).process_file()
    @output.should == "  :recycling_symbol_for_type_1_plastics => 0x2673\n"
  end
  
  it "can handle characters above 0xffff" do
    make_builder(%q{
10400;DESERET CAPITAL LETTER LONG I;Lu;0;L;;;;;N;;;;10428;
    }).process_file()
    @output.should == "  :deseret_capital_letter_long_i => 0x10400\n"
  end
  
  it "ignores entries whose names start with less than" do
    make_builder(%q{
F0000;<Plane 15 Private Use, First>;Co;0;L;;;;;N;;;;;
FFFFD;<Plane 15 Private Use, Last>;Co;0;L;;;;;N;;;;;
    }).process_file()
    @output.should == ""
  end
  
end

