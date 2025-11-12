# frozen_string_literal: true

require_relative 'lib/json_struct_mapper/version'

Gem::Specification.new do |spec|
  spec.name = 'json_struct_mapper'
  spec.version = JsonStructMapper::VERSION
  spec.authors = ['Shivani Uppala', 'Sumit Ghosh']
  spec.email = ['uppalashivani@gmail.com']

  spec.summary = 'Convert JSON data into Ruby Struct objects with bidirectional mapping'
  spec.description = 'JsonStructMapper provides an easy way to convert JSON files and hashes into Ruby Struct objects,
                      with support for nested structures and arrays. It also supports converting Structs
                      back to hashes.'
  spec.homepage = 'https://github.com/UppalaShivani/json_struct_mapper/blob/main/README.md'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/UppalaShivani/json_struct_mapper'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_dependency 'json', '~> 2.0'

  # Development dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.21'
end
