module RestEasy
  class Repository
    module RequestHandling

      private

        def raise_api_error( error, response )
          message = ( error[ 'message' ] || error[ 'Message' ] || 'Okänt fel' )

          message += "\n\n#{ response.request.inspect }" if RestEasy.debugging

          raise RestEasy::RemoteServerError, message
        end

        def validate_response( response )
          return if response.code == 200

          api_error = response.parsed_response[ 'ErrorInformation' ]
          raise_api_error( api_error, response ) if api_error
        end

        def validate_and_parse( response )
          validate_response( response )
          response.parsed_response
        end

        def execute
          self.class.set_headers( @headers )
          response = yield( self.class )
          validate_and_parse response
        end

    end
  end
end
