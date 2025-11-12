# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JsonStructMapper do
  it 'has a version number' do
    expect(JsonStructMapper::VERSION).not_to be nil
  end

  describe '.from_hash' do
    it 'converts a simple hash to struct' do
      hash = { name: 'John', age: 30 }
      converter = JsonStructMapper.from_hash(hash)

      expect(converter.object.name).to eq('John')
      expect(converter.object.age).to eq(30)
    end

    it 'handles nested hashes' do
      hash = { user: { name: 'John', address: { city: 'NYC' } } }
      converter = JsonStructMapper.from_hash(hash)

      expect(converter.object.user.name).to eq('John')
      expect(converter.object.user.address.city).to eq('NYC')
    end

    it 'handles arrays of hashes' do
      hash = { items: [{ id: 1 }, { id: 2 }] }
      converter = JsonStructMapper.from_hash(hash)

      expect(converter.object.items[0].id).to eq(1)
      expect(converter.object.items[1].id).to eq(2)
    end
  end

  describe '#to_hash' do
    it 'converts struct back to hash' do
      original_hash = { name: 'John', age: 30 }
      converter = JsonStructMapper.from_hash(original_hash)
      result_hash = converter.to_hash

      expect(result_hash).to eq(original_hash)
    end

    it 'removes nil values when compact is true' do
      hash = { name: 'John', age: nil }
      converter = JsonStructMapper.from_hash(hash)
      result_hash = converter.to_hash(compact: true)

      expect(result_hash).to eq({ name: 'John' })
    end

    it 'keeps nil values when compact is false' do
      hash = { name: 'John', age: nil }
      converter = JsonStructMapper.from_hash(hash)
      result_hash = converter.to_hash(compact: false)

      expect(result_hash).to eq(hash)
    end
  end

  describe '#to_json' do
    it 'converts struct to JSON string' do
      hash = { name: 'John', age: 30 }
      converter = JsonStructMapper.from_hash(hash)
      json = converter.to_json

      expect(JSON.parse(json)).to eq(hash.transform_keys(&:to_s))
    end

    it 'pretty prints JSON when requested' do
      hash = { name: 'John' }
      converter = JsonStructMapper.from_hash(hash)
      json = converter.to_json(pretty: true)

      expect(json).to include("\n")
    end
  end

  describe '.from_json' do
    it 'parses JSON string' do
      json_string = '{"name": "John", "age": 30}'
      converter = JsonStructMapper.from_json(json_string)

      expect(converter.object.name).to eq('John')
      expect(converter.object.age).to eq(30)
    end

    it 'raises InvalidJSONError for malformed JSON' do
      expect do
        JsonStructMapper.from_json('invalid json')
      end.to raise_error(JsonStructMapper::InvalidJSONError)
    end
  end
end
