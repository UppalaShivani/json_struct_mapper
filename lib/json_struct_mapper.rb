# frozen_string_literal: true

require_relative 'json_struct_mapper/version'
require_relative 'json_struct_mapper/errors'
require_relative 'json_struct_mapper/converter'

# JsonStructMapper provides an easy way to convert JSON data into Ruby Struct objects
module JsonStructMapper
  class << self
    # Convenience method to create a converter from a file
    def from_file(file_path, key = nil)
      Converter.new(file_path, key)
    end

    # Convenience method to create a converter from a hash
    def from_hash(hash)
      Converter.from_hash(hash)
    end

    # Convenience method to create a converter from a JSON string
    def from_json(json_string, key = nil)
      Converter.from_json(json_string, key)
    end
  end
end
