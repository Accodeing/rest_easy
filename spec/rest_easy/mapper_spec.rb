require 'spec_helper'
require 'rest_easy'
require 'rest_easy/mapper'
require 'rest_easy/examples/mapper'

describe RestEasy::Mapper do
  it_behaves_like 'mapper', nil, nil, nil, check_constants: false

  shared_examples_for 'simple mapper' do |registry_key, exp_value|
    subject{ mapper.call( value ) }
    let( :mapper ){ RestEasy::Registry[ registry_key ] }
    it{ is_expected.to eq( exp_value ) }
  end

  shared_examples_for 'identity mapper' do |registry_key|
    subject{ mapper.call( value ) }
    let( :mapper ){ RestEasy::Registry[ registry_key ] }
    it{ is_expected.to eq( value ) }
  end

  describe 'string' do
    include_examples 'identity mapper', :string do
      let( :value ){ RestEasy::Types::String[ 'test' ] }
    end
  end

  describe 'int' do
    include_examples 'identity mapper', :int do
      let( :value ){ RestEasy::Types::Integer[ 1337 ] }
    end
  end

  describe 'float' do
    include_examples 'identity mapper', :float do
      let( :value ){ RestEasy::Types::Float[ 13.37 ] }
    end
  end

  describe 'boolean' do
    include_examples 'identity mapper', :boolean do
      let( :value ){ RestEasy::Types::Boolean[ false ] }
    end
  end

  describe 'array' do
    include_examples 'identity mapper', :array do
      let( :value ){ [1,3,3,7] }
    end
  end

  describe 'array with very large int (Bigint if Ruby <2.4)' do
    include_examples 'identity mapper', :array do
      let( :value ){ [(100**10)] }
    end
  end

  describe 'advanced array' do
    include_examples 'simple mapper', :array, [ "2016-01-01", "2016-01-02" ] do
      let( :value ){ [ Date.new(2016, 1, 1), Date.new(2016, 1, 2) ] }
    end
  end

  describe 'hash' do
    include_examples 'identity mapper', :hash do
      let( :value ){ { string: 'test', int: 1337, float: 13.37 } }
    end
  end

  describe 'advanced hash' do
    expected_hash = {
      string: 'test',
      date_array: [ "2016-01-01", "2016-01-02"],
      nested_hash: { date: "2016-01-03", string: 'test' }
    }
    include_examples 'identity mapper', :hash, expected_hash do
      let( :value ) do
        {
          string: 'test',
          date_array: [Date.new(2016, 1, 1), Date.new(2016, 1, 2)],
          nested_hash: { date: Date.new(2016, 1, 3), string: 'test' }
        }
      end
    end
  end

  describe 'trueclass' do
    include_examples 'identity mapper', :trueclass do
      let( :value ){ true }
    end
  end
  describe 'falseclass' do
    include_examples 'identity mapper', :falseclass do
      let( :value ){ false }
    end
  end

  describe 'date' do
    include_examples 'simple mapper', :date, "2016-01-01" do
      let( :value ){ Date.new(2016, 1, 1) }
    end
  end

  describe 'nilclass' do
    include_examples 'identity mapper', :nilclass do
      let( :value ){ RestEasy::Types::String[ nil ] }
    end
  end

  describe '#canonical_name_sym' do
    subject{ described_class.canonical_name_sym }
    it{ is_expected.to eq( described_class.name.split( '::' ).last.downcase.to_sym ) }
  end
end
