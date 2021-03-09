require 'dry-configurable'
require 'dry-struct'
require 'json'

module RestEasy
  class State < Dry::Struct; end
  class Model
    extend Dry::Configurable


    setting :mapper, reader: true do
      setting :from_api_to_model, reader: true
      setting :from_model_to_api, reader: true
    end

    class << self
      attr_accessor :attributes
    end

    def self.attribute( name, type = Undefined )
      @attributes ||= {}
      @attributes[ name ] = type
    end

    def from_api_to_model( attributes )
      if self.class.config.mapper.from_api_to_model
        self.class.config.mapper.from_api_to_model.call( attributes )
      else
        attributes
      end
    end

    def from_model_to_api()
      if self.class.config.mapper.from_model_to_api
        self.class.config.mapper.from_model_to_api.call( @state.to_h )
      else
        @state.ho_h
      end
    end

    def initialize( **attributes )
      # Cant use a static class here since its attributes will carry over
      # between child classes
      dynamic_class = Dry.Struct( self.class.attributes || {} )
      @state = dynamic_class.new( from_api_to_model( attributes ))
    end

    def to_json()
      @state.to_h.to_json
    end

    def to_api()
      from_model_to_api().to_json
    end

    def method_missing( method_name, value = nil, &block )
      return @state[ method_name ] if @state.attributes.key? method_name.to_sym
      super
    end

    def respond_to_missing?( method_name, include_private = false )
      attribute_names.include? method_name.to_sym or super
    end
  end
end
