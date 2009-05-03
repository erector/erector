module Erector
  module Widgets #:nodoc:
    # The Table widget provides the ability to render a table from a 
    # list of objects (one for each row).
    #
    # Because the default for the column titles utilizes the ActiveSupport
    # Inflector#titleize method, this widget requires active_support to be loaded.
    #
    #   class UsersTable < Erector::Widgets::Table
    #     column :first_name
    #     column :last_name
    #     column :email
    #     row_classes :even, :odd
    #   end
    #
    #   widget UsersTable, :row_objects => [user_1, user_2, user_3]
    class Table < Erector::Widget
      ColumnDefinition = Struct.new(:id, :name, :cell_proc)
      class << self
        # Define a column, optionally specifying the name (the heading
        # that the user sees) and a block which renders the cell given
        # a row object.  If the block is not specified, the cell contains
        # the result of calling a method whose name is id.
        # 
        # The name can be a string or a proc.
        def column(id, name=id.to_s.titleize, &cell_proc)
          cell_proc ||= proc {|object| text object.__send__(id)}
          column_definitions << ColumnDefinition.new(id, name, cell_proc)
        end

        def column_definitions #:nodoc:
          @column_definitions ||= []
        end

        # A list of HTML classes to apply to the rows in turn.  After the
        # list is exhausted, start again at the start.  The most
        # common use for this is to specify one class for odd rows
        # and a different class for even rows.
        def row_classes(*row_classes)
          @row_class_list = row_classes
        end
        attr_reader :row_class_list
      end

      # The standard erector content method.
      def content
        table do
          thead do
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
          end
          tbody do
            @row_objects.each_with_index do |object, index|
              row object, index
            end
          end
        end
      end

      protected
      def row(object, index) #:nodoc:
        tr(:class => row_css_class(object, index)) do
          column_definitions.each do |column_def|
            td do
              self.instance_exec(object, &column_def.cell_proc)
            end
          end
        end
      end

      # You can override this method to provide a class for a row
      # (as an alternative to calling row_classes).
      def row_css_class(object, index)
        cycle(index)
      end

      def column_definitions #:nodoc:
        self.class.column_definitions
      end

      def cycle(index) #:nodoc:
        list = self.class.row_class_list
        list ? list[index % list.length] : ''
      end
    end
  end
end
