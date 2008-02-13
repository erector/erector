module Erector
  module Widgets
    class Table < Erector::Widget
      ColumnDefinition = Struct.new(:id, :name, :cell_proc)
      class << self
        def column(id, name=id.to_s.humanize.titleize, &cell_proc)
          cell_proc ||= proc {|object| text object.__send__(id)}
          column_definitions << ColumnDefinition.new(id, name, cell_proc)
        end

        def column_definitions
          @column_definitions ||= []
        end
      end

      def render
        table do
          tr do
            column_definitions.each do |column_def|
              th do
                h column_def.name
                end
            end
          end
          tbody do
            @row_objects.each do |object|
              tr do
                column_definitions.each do |column_def|
                  td do
                    self.instance_exec(object, &column_def.cell_proc)
                  end
                end
              end
            end
          end
        end
      end

      protected
      def column_definitions
        self.class.column_definitions
      end
    end
  end
end