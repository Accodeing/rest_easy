require 'spec_helper'

require 'rest_easy/mapper'

describe RestEasy::Mapper do
  describe 'rename' do
    before do
      class DefaultMapper < RestEasy::Mapper
        copy :good_name
        copy :choice, Proc.new{|v| v == 'TRUE' }
        copy :from, :to # Defaults to copy
        copy :int, :str, ->(v){ v.to_s }
        copy :str, :int, &:to_i
        copy :lower, :upper do |x|
          x.upcase
        end
      end
    end

    after do
      Object.send( :remove_const, :DefaultMapper )
    end

    subject{ DefaultMapper.new.call({ good_name: "value", choice: "NOT_TRUE", from: "Test", int: 12, str: "42", lower: "case" })}

    it{ is_expected.to eq({ good_name: "value", choice: false, to: "Test", str: "12", int: 42, upper: "CASE" })}
  end

  describe 'attribute mappers' do
    before do
      class DefaultMapper < RestEasy::Mapper
        def int( value )
          value.to_i
        end

        def str( value )
          value.to_s.upcase
        end
      end
    end

    after do
      Object.send( :remove_const, :DefaultMapper )
    end

    context 'with empty input' do
      subject{ DefaultMapper.new.call }

      it{ is_expected.to eq({}) }
    end

    context 'with unmapped attributes' do
      subject{ DefaultMapper.new.call( something: 123, else: "afg" )}

      it{ is_expected.to eq({})}
    end

    context 'with mapped attributes' do
      subject{ DefaultMapper.new.call( int: "123", str: "abc" )}

      it{ is_expected.to eq({ int: 123, str: "ABC" })}
    end
  end

  describe 'first/finally' do
    before do
      class DefaultMapper < RestEasy::Mapper
        # Concatenate the two name atoms into a single value
        def first( attributes )
          return { name: "#{attributes.delete( :first_name )} #{attributes.delete( :last_name )}" }
        end

        # Copy any remaining keys over to the mapped attributes
        def finally( attributes, mapped_attributes )
          keys = attributes.keys - mapped_attributes.keys
          keys.each do |key|
            mapped_attributes[ key ] = attributes[ key ]
          end
          return mapped_attributes
        end
      end
    end

    after do
      Object.send( :remove_const, :DefaultMapper )
    end

    context 'with mapped attributes' do
      subject{ DefaultMapper.new.call({ first_name: "Test", last_name: "Person", flarg: false })}

      it{ is_expected.to eq({ name: "Test Person", flarg: false })}
    end
  end

  # describe 'before' do
  #   before do
  #     class DefaultMapper < RestEasy::Mapper
  #       def first( attributes )
  #         return { name: "#{attributes[ :first_name ]} #{attributes[ :last_name ]}" }
  #       end
  #     end
  #   end
  #
  #   after do
  #     Object.send( :remove_const, :DefaultMapper )
  #   end
  #
  #   context 'with mapped attributes' do
  #     subject{ DefaultMapper.new.call({ first_name: "Test", last_name: "Person" })}
  #
  #     it{ is_expected.to eq({ name: "Test Person" })}
  #   end
  # end
end
