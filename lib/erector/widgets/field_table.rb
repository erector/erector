# A simple HTML table with three columns: label, contents, and (optionally) note.
# Each row is called a field.
# The last row can optionally contain "buttons" (actually any widget will do)
# that are all shown in the 2nd column.
# It's all surrounded with a fieldset element for a title.
# 
# In ASCII art, it looks something like this:
#
# /-Meals----------------------------------------\
# | Breakfast | eggs              |              |
# | Lunch     | sandwich          |              |
# | Dinner    | lo mein           | with shrimp! | 
# |           | [Save] [Cancel]   |              |
# \----------------------------------------------/
#
# There are two ways to create a FieldTable.
# 1. Pass a block in to the constructor.
# 2. Make a subclass.
# In both cases you'll want to call the "field" and "button" methods on the table. 
# This sets up the contents which will be rendered later during FieldTable#content.
# If you make a subclass (#2) you can do this either in the constructor or in
# the content method *before* you call super.
#
# The FieldTable is surrounded by a fieldset element whose legend is the "title" instance variable.
# Inside this fieldset is a table element.
# Each field (row of the table) has a label (th), a content cell (td), and an optional note (td).
#
# If you call "button" you can pass in a block that'll get rendered inside the 2nd column of the last row. The idea here is that you might want to make an HTML form that has a bunch of buttons at the bottom (Save, Cancel, Clear) and these all go in the same cell, with no label for the row.
#
# TODO: error messages?
# @author Alex Chaffee
class FieldTable < Erector::Widget

  include Erector::Inline
  
  class Field < Erector::Widget
    needs :label, :note => nil
    
    def content
      tr :class => "field_table_field" do
        th do
          text @label
          text ":" unless @label.nil?
        end
        td do
          super # calls the block
        end
        if @note
          td do
            text @note
          end
        end
      end
    end
  end

  # Define a field, containing a label, optional note, and block for the contents
  #
  # TODO: allow passing in a widget instead of a block
  def field(label = nil, note = nil, &contents)
    @fields << Field.new(:label => label, :note => note, &contents)
  end
  
  # If you call "button" you can pass in a block that'll get rendered inside the 2nd column of the
  # last row. The idea here is that you might want to make an HTML form that has a bunch of buttons at
  # the bottom (Save, Cancel, Clear) and these all go in the same cell, with no label for the row.
  #
  # TODO: allow passing in a widget instead of a block
  def button(&button_proc)
    @buttons << button_proc
  end

  needs :title
  
  # Pass in a block and it'll get called with a pointer to this table, so you can call
  # 'field' and 'button' to configure it
  def initialize(*args)
    super
    @fields = []
    @buttons = []
    yield self if block_given? # invoke the configuration block
  end
  
  def content
    fieldset :class => "field_table" do
      legend @title
      table :width => '100%' do
        @fields.each do |f|
          widget f
        end
        unless @buttons.empty?
          tr :class => "field_table_buttons" do
            td :colspan => 2, :align => "right" do          
              table :class => 'layout' do
                tr do
                  @buttons.each do |button|
                    td :class => "field_table_button" do
                      button.call
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  
end
