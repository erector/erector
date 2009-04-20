require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module TableSpec
  class DefaultsTestTable < Erector::Widgets::Table
    column :first_name
    column :last_name
    column :email
    row_classes :even, :odd
  end

  class CustomHeadingTable < Erector::Widgets::Table
    column :first_name, "Column - First Name"
    column :email, lambda {|id| span id}
  end

  class CustomCellTable < Erector::Widgets::Table
    column :first_name do |obj|
      span obj.first_name
    end
  end

  describe ::Erector::Widgets::Table do
    describe "with custom heading" do
      attr_reader :html, :doc
      before do
        widget = CustomHeadingTable.new(:row_objects => [])
        @html = widget.to_s
        @doc = Hpricot(html)
      end

      it "renders a custom heading text and procs" do
        table = doc.at("table")
        table.search("th").map {|c| c.inner_html}.should == [
          "Column - First Name",
          "<span>email</span>"
        ]
      end

      it "renders a tbody to be compatible with IE6" do
        doc.at("tbody").should_not be_nil
      end
    end

    describe "with custom cell content" do
      attr_reader :html, :doc
      before do
        @object1 = Struct.new(:first_name).new("Hello")
        widget = CustomCellTable.new(:row_objects => [@object1])
        @html = widget.to_s
        @doc = Hpricot(html)
      end

      it "renders custom cell html" do
        table = doc.at("table")
        row = table.search("tr")[1]
        row.at("td").inner_html.should == "<span>Hello</span>"
      end
    end

    describe "with default heading and cell definitions" do
      attr_reader :html, :doc
      before do
        @object1 = Struct.new(:first_name, :last_name, :email).new(1, 2, 3)
        @object2 = Struct.new(:first_name, :last_name, :email).new(4, 5, 6)
        @object3 = Struct.new(:first_name, :last_name, :email).new(7, 8, 9)
        widget = DefaultsTestTable.new(:row_objects => [@object1, @object2, @object3])
        @html = widget.to_s
        @doc = Hpricot(html)
        @table = doc.at("table")
      end

      it "renders column titles" do
        title_row = @table.at("tr")
        titles = title_row.search("th").collect {|heading| heading.inner_html}
        titles.should == [ "First Name", "Last Name", "Email" ]
      end

      it "renders data" do
        data_rows = @table.search("tr")[1..-1]
        cell_values = data_rows.collect do |row|
          row.search("td").collect {|col| col.inner_html}
        end

        cell_values.should == [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ]
      end

      it "renders the row classes" do
        data_rows = @table.search("tr")[1..-1]
        data_rows[0]['class'].should == 'even'
        data_rows[1]['class'].should == 'odd'
        data_rows[2]['class'].should == 'even'
      end
    end
  end
end