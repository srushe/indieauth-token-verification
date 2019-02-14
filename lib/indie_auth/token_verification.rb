require 'indie_auth/token_verification/version'
require 'net/http'
require 'json'

module IndieAuth
  class TokenVerification
    class AccessTokenMissingError < StandardError; end
    class ForbiddenUserError < StandardError; end
    class IncorrectMeError < StandardError; end
    class InsufficentScopeError < StandardError; end
    class MissingDomainError < StandardError; end
    class MissingTokenEndpointError < StandardError; end

    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token.to_s.strip.sub(/\ABearer\s*/, '')
    end

    def verify(desired_scope=nil)
      raise AccessTokenMissingError if access_token.nil? or access_token.empty?
      raise MissingDomainError if ENV.fetch('DOMAIN', nil).nil?
      raise MissingTokenEndpointError if ENV.fetch('TOKEN_ENDPOINT', nil).nil?

      response = validate_token
      raise ForbiddenUserError unless response.kind_of? Net::HTTPSuccess

      response_body = JSON.parse(response.body)
      if response_body.fetch('me', nil) != ENV['DOMAIN']
        raise IncorrectMeError, "Expected: '#{ENV['DOMAIN']}', Received: '#{response_body.fetch('me', nil)}'"
      end

      return true if desired_scope.nil?
      scope_included_in_response?(response_body, desired_scope)
    end

    private

    def validate_token
      uri = URI.parse(ENV['TOKEN_ENDPOINT'])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.get(uri.request_uri, {'Accept' => 'application/json', 'Authorization' => "Bearer #{access_token}"})
    end

    def scope_included_in_response?(response, desired_scope)
      scopes = scopes_from(response)

      return true if scopes.include?(desired_scope)
      return true if desired_scope == 'post' && scopes.include?('create')
      raise InsufficentScopeError
    end

    def scopes_from(response_body)
      return @scopes if defined? @scopes
      raise InsufficentScopeError unless response_body.key?('scope')

      @scopes ||= response_body['scope'].split
    end
  end
end