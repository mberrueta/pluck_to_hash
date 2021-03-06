require_relative "./pluck_to_hash/version"

module PluckToHash
  extend ActiveSupport::Concern

  module ClassMethods
    def pluck_to_hash(*keys)
      block_given = block_given?

      if database_adapter == :postgresql
        # http://stackoverflow.com/questions/25331778/getting-typed-results-from-activerecord-raw-sql#answer-30948357
        @type_map ||= PG::BasicTypeMapForResults.new(connection.raw_connection)
        sql = select(*keys).to_sql
        results = connection.execute(sql)
        results.type_map = @type_map
        results.map{|row| block_given ? yield(row.with_indifferent_access) : row.with_indifferent_access}
      else
        hash_type = keys[-1].is_a?(Hash) ? keys.pop.fetch(:hash_type,HashWithIndifferentAccess) : HashWithIndifferentAccess
        keys, formatted_keys = format_keys(keys)
        keys_one = keys.size == 1

        pluck(*keys).map do |row|
          value = hash_type[formatted_keys.zip(keys_one ? [row] : row)]
          block_given ? yield(value) : value
        end
      end
    end

    def pluck_to_struct(*keys)
      struct_type = keys[-1].is_a?(Hash) ? keys.pop.fetch(:struct_type,Struct) : Struct
      block_given = block_given?
      keys, formatted_keys = format_keys(keys)
      keys_one = keys.size == 1

      struct = struct_type.new(*formatted_keys)
      pluck(*keys).map do |row|
        value = keys_one ? struct.new(*[row]) : struct.new(*row)
        block_given ? yield(value) : value
      end
    end

    def format_keys(keys)
      if keys.blank?
        [column_names, column_names]
      else
        [
          keys,
          keys.map do |k|
            case k
            when String
              k.split(/\bas\b/i)[-1].strip.to_sym
            when Symbol
              k
            end
          end
        ]
      end
    end

    def database_adapter
      @postgres ||= ActiveRecord::Base.connection.adapter_name.downcase.to_sym
    end

    alias_method :pluck_h, :pluck_to_hash
    alias_method :pluck_s, :pluck_to_struct
  end
end

ActiveRecord::Base.send(:include, PluckToHash)
