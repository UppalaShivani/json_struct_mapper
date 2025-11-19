# frozen_string_literal: true

require 'json'

module JsonStructMapper
  # Converter class handles the conversion between JSON/Hash and Struct objects
  class Converter
    attr_reader :object

    # Initialize with a file path and optional key to extract from JSON
    #
    # @param file_path [String] Path to the JSON file
    # @param key [String, nil] Optional key to extract from the JSON root
    # @raise [FileNotFoundError] if file doesn't exist
    # @raise [InvalidJSONError] if JSON is malformed
    # @raise [InvalidKeyError] if specified key doesn't exist
    def initialize(file_path, key = nil)
      @object = load_from_file(file_path, key)
    end

    # Create a Converter from a hash directly
    #
    # @param hash [Hash] Hash to convert to struct
    # @return [Converter] new instance
    def self.from_hash(hash)
      instance = allocate
      instance.instance_variable_set(:@object, instance.send(:hash_to_struct, hash))
      instance
    end

    # Create a Converter from a JSON string
    #
    # @param json_string [String] JSON string to parse and convert
    # @param key [String, nil] Optional key to extract from the JSON root
    # @return [Converter] new instance
    def self.from_json(json_string, key = nil)
      data_hash = JSON.parse(json_string)
      hash = key ? data_hash[key] : data_hash
      raise InvalidKeyError, "Key '#{key}' not found in JSON" if key && hash.nil?

      from_hash(hash)
    rescue JSON::ParserError => e
      raise InvalidJSONError, "Failed to parse JSON: #{e.message}"
    end

    # Create a Converter from a JSON file, initialising with nil values
    # @param file_path [String] Path to the JSON file
    # @return [Converter] new instance
    # @raise [FileNotFoundError] if file doesn't exist
    # @raise [InvalidJSONError] if JSON is malformed
    def self.from_json_file_to_template(file_path, key = nil)
      instance = new(file_path, key) # Create an instance of the class
      struct = instance.send(:load_from_file, file_path, key) # Call the instance method
      instance.instance_variable_set(:@object, instance.send(:reset_struct_values, struct))
      instance
    end

    # Function to remove all values from a struct and initialize with nil
    #
    # @param struct [Struct] to convert
    # @return [Struct] struct with nil values
    def reset_struct_values(struct)
      struct.members.each do |member|
        value = struct[member]
        if value.is_a?(Struct)
          reset_struct_values(value) # Recursively reset nested structs
        elsif value.is_a?(Array)
          if value.any? { |item| item.is_a?(Struct) }
            value.each { |item| reset_struct_values(item) if item.is_a?(Struct) } # Reset structs inside arrays
          else
            struct[member] = nil # Set the array to nil if it doesn't contain structs
          end
        else
          struct[member] = nil
        end
      end
      struct
    end

    # Convert the struct object back to a hash
    #
    # @param compact [Boolean] whether to remove nil values
    # @return [Hash] converted hash
    def to_hash(compact: true)
      hash = struct_to_hash(@object)
      compact ? compact_hash(hash) : hash
    end

    # Convert the struct object to JSON
    #
    # @param pretty [Boolean] whether to format with indentation
    # @return [String] JSON string
    def to_json(pretty: false)
      hash = to_hash
      pretty ? JSON.pretty_generate(hash) : JSON.generate(hash)
    end

    private

    def load_from_file(file_path, key)
      raise FileNotFoundError, "File not found: #{file_path}" unless File.exist?(file_path)

      json_data = File.read(file_path)
      data_hash = JSON.parse(json_data)

      hash = key ? data_hash[key] : data_hash
      raise InvalidKeyError, "Key '#{key}' not found in JSON" if key && hash.nil?

      hash_to_struct(hash)
    rescue JSON::ParserError => e
      raise InvalidJSONError, "Failed to parse JSON: #{e.message}"
    end

    # Recursively converts a hash to a Struct
    #
    # @param hash [Hash] hash to convert
    # @return [Struct] converted struct
    def hash_to_struct(hash)
      return hash unless hash.is_a?(Hash)
      return nil if hash.is_a?(Hash) && hash.empty? # Return nil for empty hashes

      struct_class = Struct.new(*hash.keys.map(&:to_sym))
      struct_class.new(*hash.values.map { |value| convert_value_to_struct(value) })
    end

    # Convert individual values (handles Hash, Array, and primitives)
    def convert_value_to_struct(value)
      case value
      when Hash
        hash_to_struct(value)
      when Array
        value.map { |v| convert_value_to_struct(v) }
      else
        value
      end
    end

    # Converts a Struct back to a hash
    #
    # @param struct [Struct] struct to convert
    # @return [Hash] converted hash
    def struct_to_hash(struct)
      return struct unless struct.is_a?(Struct)

      struct.to_h.transform_values { |value| convert_value_to_hash(value) }
    end

    # Convert individual values back (handles Struct, Array, and primitives)
    def convert_value_to_hash(value)
      case value
      when Struct
        struct_to_hash(value)
      when Array
        value.map { |v| convert_value_to_hash(v) }
      else
        value
      end
    end

    # Recursively removes nil values from a hash
    #
    # @param hash [Hash] hash to compact
    # @return [Hash] compacted hash
    def compact_hash(hash)
      hash.each_with_object({}) do |(k, v), result|
        next if v.nil?

        result[k] = v.is_a?(Hash) ? compact_hash(v) : v
      end
    end
  end
end
