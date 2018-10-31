require 'ice_nine'

module RestEasy
  class ValidModel < RestEasy::Types::Model

    # TODO(jonas): Restructure this class a bit, it is not very readable.

    attr_accessor :unsaved, :parent

    def self.stub
      new( schema.each_with_object({}){|(key, value),hash| hash[key] = value.options[:stub] if value.options[:stub] })
    end

    def self.attribute( name, *args )
      define_method( "#{ name }?" ) do
        !send( name ).nil?
      end

      super
    end

    # TODO: There is a new meta API comming in the next release of dry-struct that will basically take care of this.
    def self.new( hash = {} )
      begin
        obj = super( hash )
        IceNine.deep_freeze( obj )
      rescue Dry::Struct::Error => e
        raise RestEasy::AttributeError.new e
      end
    end

    def unique_id
      send( self.class::UNIQUE_ID )
    end

    def update( hash )
      old_attributes = self.to_hash
      new_attributes = old_attributes.merge( hash )

      return self if new_attributes == old_attributes

      new_hash = new_attributes.delete_if{ |_, value| value.nil? }
      new_hash[:parent] = self
      self.class.new( new_hash )
    end

    # Generic comparison, by value, use .eql? or .equal? for object identity.
    def ==( other )
      return false unless other.is_a? self.class
      self.to_hash == other.to_hash
    end

    def parent?
      not @parent.nil?
    end

    def parent
      @parent || self.class.new( self.class::STUB.dup )
    end

    def to_hash( recursive = false )
      return super() if recursive

      self.class.schema.keys.each_with_object({}) do |key, result|
        result[key] = self[key]
      end
    end

  private

    def private_attributes
      @@private_attributes ||= attribute_set.select{ |a| !a.public_writer? }
    end

  end
end
