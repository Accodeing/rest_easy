require 'dry-struct'
require 'dry-types'

module RestEasy
  module Types
    include Dry::Types.module

    class Collector
      def initialize( initial_state = {} )
        @options = initial_state
      end

      def finalize
        @options
      end

      def is( *things )
        things.each_with_object(@options) do |thing, hash|
          hash[ thing.to_s.to_sym ] = true
        end
      end

      def required( options )
        stub = options.delete( :stub )

        @options[ :required ] = true
        @options[ :stub ] = stub if stub
      end

      def controls( attribute, *conditions )
        @options[ :controls ] = attribute
        @options[ :control_conditions ] = conditions
      end

      def method_missing( name, *values )
        @options[ name ] = case values.length
        when 0
          true
        when 1
          values.first
        else
          values
        end
      end
    end

    def self.new( type, &block )
      primitive = self.const_get( type.name )
      return primitive unless block_given?
      collector = Collector.new
      collector.instance_eval( &block )
      primitive.with( collector.finalize )
    end

    THE_TRUTH = { true => true, 'true' => true, false => false, 'false' => false }.freeze

    BigNum = Fixnum = Integer = Int
    Strict::BigNum = Strict::Fixnum = Strict::Integer = Strict::Int
    Coercible::BigNum = Coercible::Fixnum = Coercible::Integer = Coercible::Int
    Boolean = Bool
    Strict::Boolean = Strict::Bool

    require 'rest_easy/types/model'
  end
end
