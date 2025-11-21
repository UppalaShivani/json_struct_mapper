# JsonStructMapper

JsonStructMapper provides an easy way to convert JSON files and hashes into Ruby Struct objects, with support for nested structures and arrays. It also supports converting Structs back to hashes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_struct_mapper'
```
And then execute:
```ruby
$ bundle install
```
Or install it yourself as:
```ruby
$ gem install json_struct_mapper
```
## Usage
### From a JSON file
```ruby
# Load entire JSON file
converter = JsonStructMapper.from_file('data.json')

# Load specific key from JSON file
converter = JsonStructMapper.from_file('data.json', 'users')

# Access data via struct
converter.object.name
converter.object.email
```
### From a JSON file and create a template of the json
```ruby
# Load entire JSON file
converter = JsonStructMapper.from_json_file_to_template('data.json')

# Load specific key from JSON file
converter = JsonStructMapper.from_json_file_to_template('data.json', 'users')

# Default struct values
converter.object.name # => nil
# Assign data via struct
converter.object.name = 'Jhon'
```
### From a Hash
```ruby
hash = { name: 'John', age: 30, address: { city: 'NYC' } }
converter = JsonStructMapper.from_hash(hash)

converter.object.name # => 'John'
converter.object.address.city # => 'NYC'
```
empty hash will return nil value
```ruby
hash = { name: 'John', age: 30, address: {} }
converter = JsonStructMapper.from_hash(hash)

converter.object.address # => nil
```
### From a JSON string
```ruby
json_string = '{"name": "John", "age": 30}'
converter = JsonStructMapper.from_json(json_string)

converter.object.name # => 'John'
```
### Convert back to Hash or JSON
```ruby
# Convert to hash (removes nil values by default)
hash = converter.to_hash

# Keep nil values
hash = converter.to_hash(compact: false)

# Convert to JSON string
json = converter.to_json

# Pretty print JSON
json = converter.to_json(pretty: true)
```
### Handling nested structures
```ruby
json = {
  user: {
    name: 'John',
    contacts: [
      { type: 'email', value: 'john@example.com' },
      { type: 'phone', value: '123-456-7890' }
    ]
  }
}

converter = JsonStructMapper.from_hash(json)
converter.object.user.contacts[0].value # => 'john@example.com'
```
## Error Handling
The gem provides specific error classes:
1. JsonStructMapper::FileNotFoundError - When file doesn't exist
2. JsonStructMapper::InvalidJSONError - When JSON is malformed
3. JsonStructMapper::InvalidKeyError - When specified key doesn't exist

```ruby
begin
  converter = JsonStructMapper.from_file('missing.json')
rescue JsonStructMapper::FileNotFoundError => e
  puts "File error: #{e.message}"
end
```

## Development
After checking out the repo, run bin/setup to install dependencies. Then, run rake spec to run the tests. You can also run bin/console for an interactive prompt that will allow you to experiment.
To install this gem onto your local machine, run bundle exec rake install.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/UppalaShivani/json_struct_mapper.

## License
The gem is available as open source under the terms of the MIT License.
