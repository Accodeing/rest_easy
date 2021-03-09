require 'dry-types'

require_relative '../../lib/rest_easy/model.rb'
require_relative '../../lib/rest_easy/mapper.rb'

module Types
  include Dry.Types()
end

class MappedUser < RestEasy::Model
  attribute :name, Types::String.optional
end

class API2Model
  def self.call( attributes )
    first_name = attributes.delete( :first_name )
    last_name = attributes.delete( :last_name )
    attributes[ :name ] = "#{first_name} #{last_name}"
    return attributes
  end
end

class Model2API
  def self.call( attributes )
    name = attributes.delete( :name )
    attributes[ :first_name ] = name.split(" ").first
    attributes[ :last_name ] = name.split(" ")[1..-1].join(" ")
    return attributes
  end
end

MappedUser.configure do |config|
  config.mapper.from_api_to_model = API2Model
  config.mapper.from_model_to_api = Model2API
end
