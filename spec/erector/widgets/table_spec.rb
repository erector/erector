require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module TableSpec
  class DefaultsTestTable < Erector::Widgets::Table
    column :column_a
    column :column_b
    column :column_c
  end

  class CustomHeadingTable < Erector::Widgets::Table
    column :a, "Column - A"
  end

  class CustomCellTable < Erector::Widgets::Table
    column :a do |obj|
      span obj.a
    end
  end

  describe Erector::Widgets::Table do
    before do
      view_cache do
        widget = CustomHeadingTable.new(
          nil,
          :row_objects => []
        )
        widget.to_s
      end
    end
    
    it "renders a tbody to be compatible with IE6" do
      doc.at("tbody").should_not be_nil
    end
  end

  describe Erector::Widgets::Table, "with custom heading" do
    before do
      view_cache do
        widget = CustomHeadingTable.new(
          nil,
          :row_objects => []
        )
        widget.to_s
      end
    end
    
    it "renders a custom heading" do
      table = doc.at("table")
      table.at("th").inner_html.should == "Column - A"
    end
  end

  describe Erector::Widgets::Table, "with custom cell content" do
    before do
      @object1 = Struct.new(:a).new("Hello")
      view_cache do
        widget = CustomCellTable.new(
          nil,
          :row_objects => [@object1]
        )
        widget.to_s
      end
    end

    it "renders custom cell html" do
      table = doc.at("table")
      row = table.search("tr")[1]
      row.at("td").inner_html.should == "<span>Hello</span>"
    end
  end

  describe Erector::Widgets::Table, "with default heading and cell definitions" do
    before do
      @object1 = Struct.new(:column_a, :column_b, :column_c).new(1, 2, 3)
      @object2 = Struct.new(:column_a, :column_b, :column_c).new(4, 5, 6)
      view_cache do
        widget = DefaultsTestTable.new(
          nil,
          :row_objects => [@object1, @object2]
        )
        widget.to_s
      end
      @table = doc.at("table")
    end

    it "renders column titles" do
      title_row = @table.at("tr")
      titles = title_row.search("th").collect {|heading| heading.inner_html}
      titles.should == [ "Column A", "Column B", "Column C" ]
    end

    it "renders data" do
      data_rows = @table.search("tr")[1..-1]
      cell_values = data_rows.collect do |row|
        row.search("td").collect {|col| col.inner_html}
      end

      cell_values.should == [
        ['1', '2', '3'],
        ['4', '5', '6']
      ]
    end
  end
end