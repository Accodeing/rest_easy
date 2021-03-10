require 'spec_helper'

require 'rest_easy/model'
require 'rest_easy/mapper'
require 'middleware'

describe RestEasy::Model do

  describe 'mapper' do
    context 'using proc' do
      before do
        module Types
          include Dry.Types()
        end

        class Entity < RestEasy::Model
          attribute :name, Types::String
        end

        Entity.configure do |config|
          config.mapper.from_api_to_model = ->( attributes ) do
            attributes[:name] = attributes.delete(:first) + " " + attributes.delete(:last)
            return attributes
          end
        end
      end

      after do
        Object.send( :remove_const, :Entity )
      end

      context 'created class' do
        subject{ Entity.new( first: 'Test', last: 'Person' ) }

        it{ is_expected.to be_a Entity }
      end

      context 'processed attribute' do
        subject{ Entity.new( first: 'Test', last: 'Person' ).name }

        it{ is_expected.to eq 'Test Person' }
      end
    end

    context 'using middleware stack' do
      before do
        module Types
          include Dry.Types()
        end

        class Entity < RestEasy::Model
          attribute :value, Types::Integer
        end

        class Add < RestEasy::Mapper
          def value( value )
            value.to_i + @args[ :extra ]
          end
        end

        stack = Middleware::Builder.new do |stack|
          stack.use Add, extra: 5
        end

        Entity.configure do |config|
          config.mapper.from_api_to_model = stack
        end
      end

      after do
        Object.send( :remove_const, :Entity )
        Object.send( :remove_const, :Add )
      end

      subject{ Entity.new( value: '10' ) }

      it{ is_expected.to be_a Entity }
      its( :value ){ is_expected.to eq 15 }
    end
  end
end
