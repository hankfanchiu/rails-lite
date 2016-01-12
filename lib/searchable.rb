require_relative '../db/db_connection'

module Searchable
  def where(params)
    parameters = params.map { |col, value| "#{col} = '#{value}'" }
    conditions = parameters.join(" AND ")

    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{conditions}
    SQL

    parse_all(results)
  end
end
