module RestEasy
  module Types
    class Model < Dry::Struct
      transform_keys(&:to_sym)

      def initialize( input_attributes )
        if (missing_key = first_missing_required_key( input_attributes ))
          raise RestEasy::MissingAttributeError.new( "Missing attribute #{ missing_key.inspect } in attributes: #{ input_attributes }" )
        end

        super
      end

    private

      def missing_keys( attributes )
        non_nil_attributes = attributes.select{ |_,value| !value.nil? }

        attribute_keys = non_nil_attributes.keys
        schema_keys =  self.class.schema.keys

        schema_keys - attribute_keys
      end

      def first_missing_required_key( attributes )
        missing_keys( attributes ).find do |name|
          attribute = self.class.schema[ name ]
          attribute.respond_to?(:options) && attribute.options[:required]
        end
      end
    end

  end
end
