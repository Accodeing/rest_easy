require 'spec_helper'

require_relative '../../lib/rest_easy/mapper.rb'

describe RestEasy::Mapper do

  describe 'subclassing' do

    context 'without overriding #call' do
      before do
        class ExceptionMapper < RestEasy::Mapper; end
      end

      after do
        Object.send( :remove_const, :ExceptionMapper )
      end

      subject{ ExceptionMapper.new.method(:call) }

      its([nil]){ will raise_error(RestEasy::NotImplementedError) }
    end

    context 'when implementing #call' do
      before do
        class NoExceptionMapper < RestEasy::Mapper
          def call( something )
            return something
          end
        end
      end

      after do
        Object.send( :remove_const, :NoExceptionMapper )
      end

      subject{ NoExceptionMapper.new.method(:call) }

      its([{}]){ will_not raise_error }
      its([ first_name: "Test", last_name: "Person" ]){ is_expected.to eq({ first_name: "Test", last_name: "Person" })}
    end
  end
end
