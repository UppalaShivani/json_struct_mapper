# frozen_string_literal: true

module JsonStructMapper
  class Error < StandardError; end
  class FileNotFoundError < Error; end
  class InvalidJSONError < Error; end
  class InvalidKeyError < Error; end
end
