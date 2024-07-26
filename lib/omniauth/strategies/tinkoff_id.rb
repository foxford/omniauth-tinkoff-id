# frozen_string_literal: true

require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    # Authenticate to T-ID utilizing OAuth 2.0
    # https://developer.tbank.ru/docs/api/t-id
    class TinkoffId < OmniAuth::Strategies::OAuth2
      option :name, 'tinkoff_id'

      option :client_options, {
        site: 'https://id.tbank.ru',
        token_url: '/auth/token',
        authorize_url: '/auth/authorize',
        auth_scheme: :basic_auth
      }

      uid { raw_info['sub'] }

      extra do
        prune!({ raw_info: raw_info })
      end

      info do
        prune!(
          name: raw_info['name'],
          email: verified_email,
          unverified_email: raw_info['email'],
          email_verified: raw_info['email_verified'],
          first_name: raw_info['given_name'],
          last_name: raw_info['family_name'],
          phone_number: verified_phone_number,
          unverified_phone_number: raw_info['phone_number'],
          phone_number_verified: raw_info['phone_number_verified']
        )
      end

      def callback_url
        options[:redirect_uri] || (full_host + callback_path)
      end

      private

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end

      def raw_info
        @raw_info ||= connection.post(
          'userinfo/userinfo', client_id: options[:client_id], client_secret: options[:client_secret]
        ).body
      end

      def verified_phone_number
        raw_info['phone_number'] if raw_info['phone_number_verified']
      end

      def verified_email
        raw_info['email'] if raw_info['email_verified']
      end

      def connection
        @connection ||= Faraday.new('https://id.tbank.ru') do |conn|
          conn.request :url_encoded
          conn.request :authorization, 'Bearer', access_token.token
          conn.response :json
        end
      end
    end
  end
end
