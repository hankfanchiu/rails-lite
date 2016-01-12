require 'active_support/inflector'
require_relative '../db/db_connection'
require_relative 'searchable'
require_relative 'associatable'

class ModelBase
  extend Searchable
  extend Associatable

  def self.generate_columns
    DBConnection.execute2(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      LIMIT
        0
    SQL
  end

  def self.columns
    @columns ||= generate_columns.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}=") do |value|
        attributes[column] = value
      end

      define_method(column) do
        attributes[column]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    default_table_name = self.to_s.tableize
    table_name = instance_variable_get("@table_name")

    table_name || default_table_name
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |result| new(result) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id: id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        id = :id
    SQL

    results.empty? ? nil : parse_all(results).first
  end

  def initialize(params = {})
    params.each do |attribute, value|
      attribute = attribute.to_sym

      if columns.include?(attribute)
        send(:attributes)[attribute] = value
      else
        raise "unknown attribute '#{attribute}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    columns.map { |column| send(:attributes)[column] }
  end

  def insert
    column_names = columns.drop(1).join(", ")
    question_marks = ["?"] * (columns.length - 1)
    question_marks = question_marks.join(", ")
    attr_values = attribute_values[1..-1]

    DBConnection.execute(<<-SQL, *attr_values)
      INSERT INTO
        #{table_name} (#{column_names})
      VALUES
        (#{question_marks})
    SQL

    send(:attributes)[:id] = DBConnection.last_insert_row_id
  end

  def update
    columns_no_id = columns.drop(1)
    column_names = columns_no_id.map { |column| "#{column} = ?" }
    set_line = column_names.join(", ")
    attr_values = attribute_values.rotate

    DBConnection.execute(<<-SQL, *attr_values)
      UPDATE
        #{table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    id ? update : insert
  end

  private

  def table_name
    self.class.table_name
  end

  def columns
    self.class.columns
  end
end
