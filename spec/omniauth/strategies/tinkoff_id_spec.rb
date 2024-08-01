# frozen_string_literal: true

require 'spec_helper'

describe OmniAuth::Strategies::TinkoffId do
  subject do
    described_class.new(app, 'client_id', 'client_secret', @options || {}).tap do |strategy|
      allow(strategy).to receive(:request) do
        request
      end
    end
  end

  let(:request) { double('Request', params: {}, cookies: {}, env: {}, query_string: {}) }
  let(:app) do
    lambda do
      [200, {}, ['Hello.']]
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe '#client_options' do
    it 'has correct site' do
      expect(subject.client.site).to eq('https://id.tbank.ru')
    end

    it 'has correct authorize_url' do
      expect(subject.client.options[:authorize_url]).to eq('/auth/authorize')
    end

    it 'has correct token_url' do
      expect(subject.client.options[:token_url]).to eq('/auth/token')
    end

    describe 'overrides' do
      context 'as strings' do
        it 'allows overriding the site' do
          @options = { client_options: { 'site' => 'https://example.com' } }
          expect(subject.client.site).to eq('https://example.com')
        end

        it 'allows overriding the authorize_url' do
          @options = { client_options: { 'authorize_url' => 'https://example.com' } }
          expect(subject.client.options[:authorize_url]).to eq('https://example.com')
        end

        it 'allows overriding the token_url' do
          @options = { client_options: { 'token_url' => 'https://example.com' } }
          expect(subject.client.options[:token_url]).to eq('https://example.com')
        end
      end

      context 'as symbols' do
        it 'allows overriding the site' do
          @options = { client_options: { site: 'https://example.com' } }
          expect(subject.client.site).to eq('https://example.com')
        end

        it 'allows overriding the authorize_url' do
          @options = { client_options: { authorize_url: 'https://example.com' } }
          expect(subject.client.options[:authorize_url]).to eq('https://example.com')
        end

        it 'allows overriding the token_url' do
          @options = { client_options: { token_url: 'https://example.com' } }
          expect(subject.client.options[:token_url]).to eq('https://example.com')
        end
      end
    end
  end

  describe '#callback_url' do
    let(:base_url) { 'https://example.com' }

    it 'returns correct default callback path' do
      allow(subject).to receive(:full_host) { base_url }
      allow(subject).to receive(:script_name).and_return('')
      expect(subject.send(:callback_url)).to eq("#{base_url}/auth/tinkoff_id/callback")
    end

    it 'sets the callback path with script_name if present' do
      allow(subject).to receive(:full_host) { base_url }
      allow(subject).to receive(:script_name).and_return('/v1')
      expect(subject.send(:callback_url)).to eq("#{base_url}/v1/auth/tinkoff_id/callback")
    end

    it 'sets the callback_path parameter if present' do
      @options = { callback_path: '/auth/foo/callback' }
      allow(subject).to receive(:full_host) { base_url }
      allow(subject).to receive(:script_name).and_return('')
      expect(subject.send(:callback_url)).to eq("#{base_url}/auth/foo/callback")
    end
  end

  describe '#info' do
    let(:client) { OAuth2::Client.new('abc', 'def') }
    let(:access_token) do
      OAuth2::AccessToken.from_hash(client, access_token: 'valid_access_token',
                                            token_type: 'Bearer',
                                            expires_at: 1791,
                                            refresh_token: 'valid_refresh_token')
    end

    before do
      allow(subject).to receive(:access_token).and_return(access_token)
    end

    let(:response_hash) do
      {
        email: 'tinkoff@mail.ru',
        family_name: 'Иванов',
        birthdate: '2000-01-01',
        sub: '923d4812-148c-45v4-a56b-eed15cdd2857',
        name: 'Иванов Олег',
        gender: 'male',
        phone_number: '+79998887766',
        middle_name: 'Юрьевич',
        given_name: 'Олег',
        email_verified: false,
        phone_number_verified: false
      }
    end

    before do
      stub_request(:post, 'https://id.tbank.ru/userinfo/userinfo')
        .with(
          body: { 'client_id' => 'client_id', 'client_secret' => 'client_secret' },
          headers: {
            'Accept' => '*/*',
            'Authorization' => "Bearer #{access_token.token}",
            'Content-Type' => 'application/x-www-form-urlencoded'
          }
        )
        .to_return(status: 200, body: response_hash.to_json, headers: { 'Content-Type': 'application/json' })
    end

    it 'retunrs info hash' do
      expect(subject.info).to eq(
        name: 'Иванов Олег',
        unverified_email: 'tinkoff@mail.ru',
        email_verified: false,
        first_name: 'Олег',
        last_name: 'Иванов',
        phone_number_verified: false,
        unverified_phone_number: '+79998887766'
      )
    end

    context 'with verified email' do
      let(:response_hash) do
        { email_verified: true, email: 'tinkoff@mail.ru' }
      end

      it 'returns info with email' do
        expect(subject.info[:email]).to eq('tinkoff@mail.ru')
      end
    end

    context 'when verified phone number' do
      let(:response_hash) do
        { phone_number_verified: true, phone_number: '+79998887766' }
      end

      it 'returns info with email' do
        expect(subject.info[:phone_number]).to eq('+79998887766')
      end
    end
  end

  describe '#credentials' do
    let(:client) { OAuth2::Client.new('abc', 'def') }
    let(:access_token) do
      OAuth2::AccessToken.from_hash(client, access_token: 'valid_access_token',
                                            token_type: 'Bearer',
                                            expires_at: 1791,
                                            refresh_token: 'valid_refresh_token')
    end

    before do
      allow(subject).to receive(:access_token).and_return(access_token)
      subject.options.client_options[:connection_build] = proc do |builder|
        builder.request :url_encoded
        builder.request :basic_auth, :basic, subject.client.options[:client_id], subject.client.options[:client_secrect]
        builder.adapter :test do |stub|
          stub.post('/auth/token') do
            [200, { 'Content-Type' => 'application/json; charset=UTF-8' }, JSON.dump(
              sub: '2xxxxxxc-8xx6-4xxd-9xx5-bxxxxxxxxxxa'
            )]
          end
        end
      end
    end

    it 'returns access token and (optionally) refresh token' do
      expect(subject.credentials.to_h)
        .to match(hash_including(
                    {
                      'expires' => true,
                      'expires_at' => 1791,
                      'refresh_token' => 'valid_refresh_token',
                      'token' => 'valid_access_token'
                    }
                  ))
    end
  end
end
