require 'spec_helper'
require 'rest_easy'

describe RestEasy::Repository do
  before do
    RestEasy.configure do |config|
      config.base_url = 'https://api.example.com/v1/'
    end
  end

  using_test_class do
    module Model
      class Test
      end
    end
    module Repository
      class Test < RestEasy::Repository
        MODEL = Model::Test
      end
    end

    require 'dry/container/stub'
    RestEasy::Registry.enable_stubs!
    RestEasy::Registry.stub( :test, Model::Test )
  end

  let(:access_token){ '3f08d038-f380-4893-94a0-a08f6e60e67a' }
  let(:access_token2){ '89feajou-sif8-8f8u-29ja-xdfniokeniod' }
  let(:client_secret){ 'P5K5vE3Kun' }
  let(:repository){ Repository::Test.new }
  let(:application_json){}
  let(:headers) do
    {
      'Access-Token' => access_token,
      'Client-Secret' => client_secret,
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
    }
  end

  describe 'creation' do
    shared_examples_for 'missing configuration' do
      subject{ ->{ repository } }

      let(:error){ RestEasy::MissingConfiguration }

      it{ is_expected.to raise_error( error, /#{message}/ ) }
    end

    context 'without base url' do
      include_examples 'missing configuration' do
        before{ RestEasy.configure{ |conf| conf.base_url = nil } }
        let(:message){ 'have to provide a base url' }
      end
    end

    context 'without client secret' do
      include_examples 'missing configuration' do
        before{ RestEasy.configure{ |conf| conf.client_secret = nil } }
        let(:message){ 'have to provide your client secret' }
      end
    end
  end

  context 'when making a request including the proper headers' do
    before do
      RestEasy.configure do |conf|
        conf.client_secret = client_secret
        conf.access_token = access_token
      end

      stub_request(
        :get,
        'https://api.example.com/v1/test',
      ).with(
        headers: {
          'Client-Secret' => client_secret,
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
        }
      ).to_return(
        status: 200
      )
    end

    subject{ repository.get( '/test', { body: '' } ) }

    it{ is_expected.to be_nil }
  end

  context 'when raising error from remote server' do
    before do
      RestEasy.configure do |conf|
        conf.client_secret = client_secret
        conf.access_tokens = [access_token, access_token2]
      end

      stub_request(
        :post,
        'https://api.example.com/v1/test',
      ).to_return(
        status: 500,
        body: { 'ErrorInformation' => { 'error' => 1, 'message' => 'Räkenskapsår finns inte upplagt. För att kunna skapa en faktura krävs det att det finns ett räkenskapsår' } }.to_json,
        headers: { 'Content-Type' => 'application/json' },
      )
    end

    subject{ ->{ repository.post( '/test', { body: '' } ) } }

    it{ is_expected.to raise_error( RestEasy::RemoteServerError ) }
    it{ is_expected.to raise_error( 'Räkenskapsår finns inte upplagt. För att kunna skapa en faktura krävs det att det finns ett räkenskapsår' ) }

    context 'with debugging enabled' do
      around do |example|
        RestEasy.config.debugging = true
        example.run
        RestEasy.config.debugging = false
      end

      it{ is_expected.to raise_error( /\<HTTParty\:\:Request\:0x/ ) }
    end
  end
end
