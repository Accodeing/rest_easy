class User < RestEasy::ValidModel

  attribute :id, RestEasy::Types.new( Integer ) {
    unique_id
  }

  attribute :first_name, RestEasy::Types.new( String ) {
    stub ''
    required
    searchable
    whatever 1, 'arg', :foo
  }

  attribute :last_name, RestEasy::Types.new( String ) {
    stub ''
    is :required, :searchable
    whatever 1, 'arg', :foo
  }

  attribute :avatar, RestEasy::Types.new( String )
end
