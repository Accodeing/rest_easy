require 'set'
require 'dry-struct'
require 'rest_easy/version'
require 'logger'

module RestEasy

  extend Dry::Configurable

  DEFAULT_CONFIGURATION = {
    base_url: nil,
    client_secret: nil,
    token_store: {},
    access_token: nil,
    access_tokens: nil,
    debugging: false,
    logger: ->{
      logger = Logger.new(STDOUT)
      logger.level = Logger::WARN
      return logger
    }.call,
  }.freeze

  setting :base_url, DEFAULT_CONFIGURATION[:base_url]
  setting :client_secret, DEFAULT_CONFIGURATION[:client_secret]
  setting :token_store, DEFAULT_CONFIGURATION[:token_store]
  setting :access_token, DEFAULT_CONFIGURATION[:access_token] do |value|
    next if value == nil # nil is a valid unassigned value
    invalid_access_token_format!(value) unless value.is_a?(String)
    config.token_store = { default: value }
    value
  end
  setting :access_tokens, DEFAULT_CONFIGURATION[:access_tokens] do |value|
    next if value == nil # nil is a valid unassigned value
    invalid_access_tokens_format!(value) unless value.is_a?(Hash) || value.is_a?(Array)
    config.token_store = value.is_a?(Hash) ? value : { default: value }
    value
  end
  setting :debugging, DEFAULT_CONFIGURATION[:debugging], reader: true
  setting :logger, DEFAULT_CONFIGURATION[:logger], reader: true

  Registry = Dry::Container.new

  class Exception < StandardError
  end

  class AttributeError < RestEasy::Exception
  end

  class RemoteServerError < RestEasy::Exception
  end

  class MissingAttributeError < RestEasy::Exception
  end

  class MissingConfiguration < RestEasy::Exception
  end

  def self.invalid_access_token_format!(value)
    raise ArgumentError, "expected a String, but #{ value.inspect } has class #{ value.class }"
  end
  private_class_method :invalid_access_token_format!

  def self.invalid_access_tokens_format!(value)
    raise ArgumentError, "expected a Hash or an Array, but #{ value.inspect } has class #{ value.class }"
  end
  private_class_method :invalid_access_tokens_format!
end

require 'rest_easy/model'
require 'rest_easy/repository'
require 'rest_easy/mapper'
