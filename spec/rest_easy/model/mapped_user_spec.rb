require 'spec_helper'

require_relative '../../examples/mapped_user.rb'

describe MappedUser do
  let( :user ){ MappedUser.new( first_name: "Test", last_name: "Person" ) }

  subject{ user }

  its( :name ){ is_expected.to eq "Test Person" }
  its( :first_name ){ will raise_error( NoMethodError, /first_name/ )}
  its( :last_name ){ will raise_error( NoMethodError, /last_name/ )}
  its( :to_json ){ is_expected.to eq(
    { name: "Test Person" }.to_json
  )}
  its( :to_api ){ is_expected.to eq(
    { first_name: "Test", last_name: "Person" }.to_json
  )}
end
