require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: "#{name}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: "#{self_class_name.to_s.underscore}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.singularize.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  def assoc_options
    @assoc_options ||= {}
  end
  
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      primary_key = options.primary_key
      foreign_key = options.foreign_key
      model_class = options.model_class
      id_value = self.send(foreign_key)

      model_class.where(primary_key => id_value).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    assoc_options[name] = options

    define_method(name) do
      primary_key = options.primary_key
      foreign_key = options.foreign_key
      model_class = options.model_class
      id_value = self.send(primary_key)

      model_class.where(foreign_key => id_value)
    end
  end

  def has_one_through(name, thru_name, source_name)
    define_method(name) do
      thru_options    = self.class.assoc_options[thru_name]
      thru_class      = thru_options.model_class
      thru_table      = thru_options.table_name
      thru_primary    = thru_options.primary_key
      thru_foreign    = thru_options.foreign_key

      source_options  = thru_class.assoc_options[source_name]
      source_class    = source_options.model_class
      source_table    = source_options.table_name
      source_primary  = source_options.primary_key
      source_foreign  = source_options.foreign_key

      self_foreign    = self.send(thru_foreign)

      results = DBConnection.execute(<<-SQL)
        SELECT
          #{source_table}.*
        FROM
          #{thru_table}
        JOIN
          #{source_table}
        ON
          #{source_table}.#{source_primary} = #{thru_table}.#{source_foreign}
        WHERE
          #{thru_table}.#{thru_primary} = #{self_foreign}
      SQL

      source_class.new(results.first)
    end
  end
end
