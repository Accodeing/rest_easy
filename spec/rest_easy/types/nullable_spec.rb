require 'spec_helper'
require 'dry-struct'
require 'rest_easy/types'

describe RestEasy::Types::Nullable, type: :type do
  subject{ TestStruct }

  describe 'String' do
    using_test_class do
      class TestStruct < Dry::Struct
        attribute :string, RestEasy::Types::Nullable::String
      end
    end

    it{ is_expected.to have_nullable(:string, 'A simple message', 0, '0') }
  end

  describe 'Float' do
    using_test_class do
      class TestStruct < Dry::Struct
        attribute :float, RestEasy::Types::Nullable::Float
      end
    end

    it{ is_expected.to have_nullable(:float, 14.0, 'Not a Float!', 0.0) }
  end

  describe 'Integer' do
    using_test_class do
      class TestStruct < Dry::Struct
        attribute :integer, RestEasy::Types::Nullable::Integer
      end
    end

    it{ is_expected.to have_nullable(:integer, 14, 14.0, 14) }
  end

  describe 'Boolean' do
    using_test_class do
      class TestStruct < Dry::Struct
        attribute :boolean, RestEasy::Types::Nullable::Boolean
      end
    end

    it{ is_expected.to have_nullable(:boolean, true, 'Not a Boolean!', false) }
  end

  describe 'Date' do
    using_test_class do
      class TestStruct < Dry::Struct
        attribute :date, RestEasy::Types::Nullable::Date
      end
    end

    it{ is_expected.to have_nullable_date(:date, Date.new(2016, 1, 1), 'Not a Date!') }
  end
end
