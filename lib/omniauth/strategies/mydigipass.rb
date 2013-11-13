require 'omniauth-oauth2'
require 'mydigipass/tools'

module OmniAuth
  module Strategies
    class Mydigipass < OmniAuth::Strategies::OAuth2
      def self.default_client_urls(options = { })
        base_uri = ::Mydigipass::Tools.extract_base_uri_from_options(options)
        {
          :site          => base_uri,
          :authorize_url => base_uri + '/oauth/authenticate',
          :token_url     => base_uri + '/oauth/token'
        }
      end

      option :name, 'mydigipass'
      option :client_options, default_client_urls
      option :provider_ignores_state, true

      # These are called after authentication has succeeded.
      uid { raw_info['uuid'] }

      info do
        {
          :name => "#{raw_info['first_name']} #{raw_info['last_name']}",
          :email => raw_info['email'],
          :nickname => raw_info['login'],
          :first_name => raw_info['first_name'],
          :last_name => raw_info['last_name'],
          :location => "#{raw_info['address_1']}, #{raw_info['zip']} #{raw_info['city']}, #{raw_info['country']}",
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth/user_data').parsed
      end
    end
  end
end