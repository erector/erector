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

        def row_classes(*row_classes)
          @row_class_list = row_classes
        end
        attr_reader :row_class_list
      end

      def render
        table do
          tr do
            column_definitions.each do |column_def|
              th do
                if column_def.name.is_a?(Proc)
                  self.instance_exec(column_def.id, &column_def.name)
                else
                  text column_def.name
                end
              end
            end
          end
          tbody do
            @row_objects.each_with_index do |object, index|
              row object, index
            end
          end
        end
      end

      protected
      def row(object, index)
        tr(:class => row_css_class(index)) do
          column_definitions.each do |column_def|
            td do
              self.instance_exec(object, &column_def.cell_proc)
            end
          end
        end
      end

      def row_css_class(index)
        cycle(index)
      end

      def column_definitions
        self.class.column_definitions
      end

      def cycle(index)
        list = self.class.row_class_list
        list ? list[index % list.length] : ''
      end
    end
  end
end