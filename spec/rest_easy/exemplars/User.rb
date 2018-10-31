DiscountTypes = RestEasy::Types::Strict::String.enum( 'AMOUNT', 'PERCENT' )

class User < RestEasy::Model
  attribute :id, RestEasy::Types.new( Integer ) {
    unique_id
  }

  attribute :first_name, RestEasy::Types.new( String ) {
    required stub: ''
    searchable
    whatever 1, 'arg', :foo
  }

  attribute :last_name, RestEasy::Types.new( String ) {
    is :required, :searchable
    stub ''
    whatever 1, 'arg', :foo
  }

  attribute :discount_type, RestEasy::Types.new( DiscountTypes ) {
    on_change -> instance, new_value {

    }
  }

  attribute :discount, RestEasy::Types.new( Float ) {

  }.constrained(gteq: 0.0, lteq: 100.0)

  attribute :avatar, RestEasy::Types.new( String )
end
