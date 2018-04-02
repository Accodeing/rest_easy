require 'rest_easy/mapper/from_json'
require 'rest_easy/mapper/to_json'
require 'rest_easy/types'

module RestEasy
  class Mapper
    include FromJSON
    include ToJSON

    Identity = ->(value){ value }

    ToString = ->(value){ value.to_s }

    Array = ->(array) do
      array.each_with_object( [] ) do |item, converted_array|
        name = RestEasy::Mapper.canonical_name_sym( item )
        converted_array << RestEasy::Registry[ name ].call( item )
      end
    end

    Hash = ->(hash) do
      hash.each do |key, value|
        name = RestEasy::Mapper.canonical_name_sym( value )
        hash[key] = RestEasy::Registry[ name ].call( value )
      end
    end

    Registry.register( :fixnum, RestEasy::Mapper::Identity ) # TODO: Legacy support, remove when 2.4 support is dropped
    Registry.register( :bignum, RestEasy::Mapper::Identity ) # TODO: Legacy support, remove when 2.4 support is dropped
    Registry.register( :integer, RestEasy::Mapper::Identity )
    Registry.register( :int, RestEasy::Mapper::Identity )
    Registry.register( :float, RestEasy::Mapper::Identity )
    Registry.register( :string, RestEasy::Mapper::Identity )
    Registry.register( :boolean, RestEasy::Mapper::Identity )
    Registry.register( :falseclass, RestEasy::Mapper::Identity )
    Registry.register( :trueclass, RestEasy::Mapper::Identity )
    Registry.register( :nilclass, RestEasy::Mapper::Identity )
    Registry.register( :date, RestEasy::Mapper::ToString )
    Registry.register( :account_number, RestEasy::Mapper::Identity )
    Registry.register( :country_code, RestEasy::Mapper::Identity )
    Registry.register( :currency, RestEasy::Mapper::Identity )
    Registry.register( :customer_type, RestEasy::Mapper::Identity )
    Registry.register( :discount_type, RestEasy::Mapper::Identity )
    Registry.register( :email, RestEasy::Mapper::Identity )
    Registry.register( :house_work_type, RestEasy::Mapper::Identity )
    Registry.register( :vat_type, RestEasy::Mapper::Identity )
    Registry.register( :labels, RestEasy::Mapper::Array )
    Registry.register( :array, RestEasy::Mapper::Array )
    Registry.register( :hash, RestEasy::Mapper::Hash )

    def self.canonical_name_sym( klass = self )
      klass = klass.class unless klass.is_a? Class
      klass.name.split( '::' ).last.downcase.to_sym
    end

    def self.inherited( subclass )
      Registry.register( canonical_name_sym( subclass ), subclass )
    end

    def diff( entity_hash, parent_hash )
      hash_diff( entity_hash[self.class::JSON_ENTITY_WRAPPER],
                 parent_hash[self.class::JSON_ENTITY_WRAPPER] )
    end

  private

    def hash_diff( hash1, hash2 )
      hash1.dup.
        delete_if{ |k, v| hash2[k] == v }.
        merge!(hash2.dup.delete_if{ |k, _| hash1.has_key?(k) })
    end
  end
end
