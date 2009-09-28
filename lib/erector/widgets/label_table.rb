# A simple HTML table with three columns: label, contents, and (optionally) note.
# Each row is called a field.
# To create a LabelTable, ...
class LabelTable < Erector::Widget

  include Erector::Inline
  
  class Field < Erector::Widget
    needs :label, :note => nil
    
    def content
      tr do
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

  def field(label, note = nil, &contents)
    @fields << Field.new(:label => label, :note => note, &contents)
  end
  
  def button(&button_proc)
    @buttons << button_proc
  end

  needs :title
  
  def initialize(*args)
    super
    @fields = []
    @buttons = []
#    yield self
  end
  
  def content
    super
    fieldset :class => "label_table" do
      legend @title
      table :width => '100%' do
        @fields.each do |f|
          widget f
        end
        tr do
          td :colspan => 2, :align => "right" do          
            table :class => 'layout' do
              tr do
                @buttons.each do |button|
                  td do
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
