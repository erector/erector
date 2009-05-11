require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

require "erector/erect"

module Erector
  describe Erect do
    it "parses an empty command line" do
      erect = Erect.new([])
      erect.files.should == []
    end
    
    it "parses a command line with one filename on it" do
      erect = Erect.new(["foo.html"])
      erect.files.should == ["foo.html"]
    end
    
    it "parses a command line with several filenames on it" do
      erect = Erect.new(["foo.html", "bar/baz.html"])
      erect.files.should == ["foo.html", "bar/baz.html"]
    end
    
    it "is verbose by default, but quiet when told" do
      Erect.new([]).verbose.should be_true
      Erect.new(["-q"]).verbose.should be_false
    end

    it "parses a command line with several filenames and an option on it" do
      erect = Erect.new(["-q", "foo.html", "bar/baz.html"])
      erect.files.should == ["foo.html", "bar/baz.html"]
    end
 
    def capturing_output
      output = StringIO.new
      $stdout = output
      yield
      output.string
    ensure
      $stdout = STDOUT
    end
    
    it "exits immediately from help" do
      output = capturing_output do
        lambda {
          erect = Erect.new(["-h"])
        }.should raise_error(SystemExit)
      end
      output.should =~ /^Usage/
    end
    
    it "exits immediately from --version" do
      output = capturing_output do
        lambda {
          erect = Erect.new(["--version"])
        }.should raise_error(SystemExit)
      end
      output.should == Erector::VERSION + "\n"
    end
    
    it "changes to html output" do
      erect = Erect.new(["--to-html"])
      erect.mode.should == :to_html
    end

    it "changes to html output when passed a .rb file" do
      pending do
        erect = Erect.new(["foo.rb"])
        erect.mode.should == :to_html
      end
    end

    it "fails when given both .rb and .html files" do
      pending do
        lambda {
          erect = Erect.new(["foo.rb", "bar.html"])
        }.should raise_error
      end
    end
    
    it "returns false when there's an error during run" do
      capturing_output do
        Erect.new(["MISSINGFILE"]).run.should == false
      end
        
    end
    
  end
  
  describe "Erect functionally" do
    
    attr_reader :dir, :fred_html, :wilma_rhtml, :barney_html_erb, :fred_rb
    
    def create(file, body="hi")
      File.open(file, "w") do |f|
        f.puts(body)
      end
    end
    
    before :all do
      @dir = Dir.tmpdir + "/#{Time.now.to_i}" + "/explode"
      @fred_html = "#{dir}/fred.html"
      @wilma_rhtml = "#{dir}/wilma.rhtml"
      @barney_html_erb = "#{dir}/barney.html.erb"
      @fred_rb = "#{dir}/fred.rb"

      FileUtils.mkdir_p(dir)
      create(fred_html)
      create(wilma_rhtml)
      create(barney_html_erb)
      create(fred_rb, "class Fred < Erector::Widget\ndef content\ndiv 'dino'\nend\nend")
    end
    
    it "explodes dirs into .html etc. files when in to-rb mode" do
      erect = Erect.new(["--to-erector", dir])
      erect.files.sort.should == [barney_html_erb, fred_html, wilma_rhtml]
    end
    
    it "explodes dirs into .rb files when in to-html mode" do    
      erect = Erect.new(["--to-html", dir])
      erect.files.should == [fred_rb]
    end
    
    it "outputs .rb files in the same directory as the input .html files" do
      erect = Erect.new(["--to-erector", "-q", fred_html])
      erect.run
      File.exist?(fred_rb).should be_true
      File.read(fred_rb).should include("text 'hi'")
    end
    
    it "outputs .html files in the same directory as the input .rb files" do
      betty_rb = "#{dir}/betty.rb"
      betty_html = "#{dir}/betty.html"
      create(betty_rb, "class Betty < Erector::Widget\ndef content\ndiv 'bam bam'\nend\nend")

      erect = Erect.new(["--to-html", "-q", betty_rb])
      erect.run
      File.exist?(betty_html).should be_true
      File.read(betty_html).should == "<div>bam bam</div>\n"
    end
    
    it "outputs .html files in the given directory" do
      create(fred_rb, "class Fred < Erector::Widget\ndef content\ndiv 'dino'\nend\nend")
      out_dir = "#{dir}/out"
      out_file = "#{out_dir}/fred.html"

      Erect.new([]).output_dir.should be_nil
      erect = Erect.new(["--to-html", "-o", "#{out_dir}", "-q", fred_rb])
      erect.output_dir.should == out_dir
      erect.run
      File.exist?(out_file).should be_true
      File.read(out_file).should == "<div>dino</div>\n"
    end
    
    it "skips rendering classes that aren't widgets" do
      mr_slate_rb = "#{dir}/mr_slate.rb"
      mr_slate_html = "#{dir}/mr_slate.html"
      create(mr_slate_rb, "class MrSlate\nend")
      erect = Erect.new(["-q", "--to-html", mr_slate_rb])
      erect.run
      File.exist?(mr_slate_html).should be_false
    end
    
    # it "properly indents lines beginning with for, unless, etc."
    # it "escapes single quotes inside text strings"
  end

end
