class HomeController < ApplicationController
  require 'csv'

  def index
  end

  def import
    filename = params[:file].original_filename.split('.').first

    id = 1
    CSV.foreach(params[:file].path, headers: true) do |row|
      attributes = row.to_hash.keys
      unless ActiveRecord::Base.connection.table_exists?(filename.to_sym)
        ActiveRecord::Base.connection.create_table filename.to_sym do |t|
          attributes.each do |key|
            t.string key.to_sym
          end
        end
      end
      values = row.to_hash.values.map { |v| "'#{v}'" }.join(',')
      query = "INSERT INTO #{filename} VALUES (#{id},#{values})"
      ActiveRecord::Base.connection.execute(query)
      id += 1
    end
  end
end
