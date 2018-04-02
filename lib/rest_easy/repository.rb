require 'httparty'
require 'rest_easy/repository/request_handling'
require 'rest_easy/repository/loaders'
require 'rest_easy/repository/savers'

module RestEasy
  class Repository
    include HTTParty
    include RequestHandling
    include Loaders
    include Savers

    HTTParty::Parser::SupportedFormats[ "text/html" ] = :json

    DEFAULT_HEADERS = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
    }.freeze

    HTTP_METHODS = [ :get, :put, :post, :delete ].freeze

    attr_accessor :headers
    attr_reader :mapper, :keys_filtered_on_save

    def self.set_headers( headers = {} )
      self.headers.merge!( headers )
    end

    HTTP_METHODS.each do |method|
      define_method method do |*args|
        # Call midleware somehow ...
        # self.headers['Access-Token'] = next_access_token
        execute do |remote|
          remote.send( method, *args )
        end
      end
    end

    def initialize( keys_filtered_on_save: [ :url ], token_store: :default )
      self.class.base_uri( get_base_url )

      self.headers = DEFAULT_HEADERS.merge({
        'Client-Secret' => get_client_secret,
      })

      @keys_filtered_on_save = keys_filtered_on_save
      @token_store = token_store
      @mapper = Registry[ Mapper.canonical_name_sym( self.class::MODEL )].new
    end

    def next_access_token
      @access_tokens ||= CircularQueue.new( *get_access_tokens )
      @access_tokens.next
    end

    def check_access_tokens!( tokens )
      if tokens == nil or tokens.empty?
        fail MissingConfiguration, "You have not provided any access tokens in token store #{ @token_store.inspect }."
      end
    end

    def get_access_tokens
      begin
        tokens = config.token_store.fetch( @token_store )
      rescue KeyError
        token_store_not_found!( @token_store.inspect )
      end

      check_access_tokens!( tokens )
      tokens
    end

    private

      def instantiate( hash )
        hash[ :new ] = false
        hash[ :unsaved ] = false
        self.class::MODEL.new( hash )
      end

      def get_base_url
        base_url = config.base_url
        fail MissingConfiguration, 'You have to provide a base url.' unless base_url
        base_url
      end

      def get_client_secret
        client_secret = config.client_secret
        fail MissingConfiguration, 'You have to provide your client secret.' unless client_secret
        client_secret
      end

      def config
        RestEasy.config
      end

      def token_store_not_found!( store_name )
        fail MissingConfiguration,
             "There is no token store named #{ store_name }. Available stores are #{ config.token_store.keys }."
      end
  end
end
