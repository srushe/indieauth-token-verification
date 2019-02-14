require 'spec_helper'

def with_modified_environment(options, &block)
  ClimateControl.modify(options, &block)
end

RSpec.shared_examples_for 'a successful verification' do
  context 'the token endpoint is used to verify the token' do
    let(:expected_headers) do
      {
        'Accept' => 'application/json',
        'Authorization' => 'Bearer some-token'
      }
    end

    before do
      verifier.verify
    end

    it { expect(Net::HTTP).to have_received(:new).with(token_endpoint_uri.host, token_endpoint_uri.port) }
    it { expect(http_object).to have_received(:use_ssl=).with(true) }
    it { expect(http_object).to have_received(:get).with(token_endpoint_uri.request_uri, expected_headers) }
  end

  context 'when a scope is provided' do
    subject { verifier.verify('create') }

    it { expect(subject).to be true }
  end

  context 'when no scope is provided' do
    subject { verifier.verify }

    it { expect(subject).to be true }
  end
end

RSpec.describe IndieAuth::TokenVerification do
  it "has a version number" do
    expect(IndieAuth::TokenVerification::VERSION).not_to be nil
  end

  let(:domain) { 'https://example.org/' }
  let(:token_endpoint_url) { 'https://example.com/token' }
  let(:token_endpoint_uri) { instance_double(URI::HTTPS, request_uri: '/token', host: 'example.org', port: 443) }
  let(:http_object) { instance_double(Net::HTTP) }
  let(:token_response) do
    double(:http_response, body: response_body)
  end
  let(:response_successful) { true }
  let(:response_body) { "{\"scope\":\"create update delete undelete\",\"me\":\"#{domain}\"}" }

  before do
    allow(URI).to receive(:parse) { token_endpoint_uri }
    allow(Net::HTTP).to receive(:new) { http_object }
    allow(http_object).to receive(:use_ssl=)
    allow(http_object).to receive(:get) { token_response }
    allow(token_response).to receive(:kind_of?).with(Net::HTTPSuccess) { response_successful }
  end

  context 'when no error occurs' do
    let(:verifier) { described_class.new(access_token) }
    let(:environment) do
      { TOKEN_ENDPOINT: token_endpoint_url, DOMAIN: domain }
    end

    around do |example|
      with_modified_environment(environment) { example.run }
    end

    context 'and the access_token starts with "Bearer "' do
      let(:access_token) { 'Bearer some-token' }

      it_behaves_like 'a successful verification'
    end

    context 'and the access is plain' do
      let(:access_token) { 'some-token' }

      it_behaves_like 'a successful verification'
    end
  end

  context 'when an error occurs' do
    let(:verifier) { described_class.new(access_token) }
    let(:access_token) { 'some.token' }

    context 'due to the access_token being invalid' do
      subject(:verify) { verifier.verify }

      ['', '   ', nil, 'Bearer', 'Bearer   '].each do |invalid_access_token|
        context "when it is '#{invalid_access_token.nil? ? 'nil' : invalid_access_token}'" do
          let(:access_token) { invalid_access_token }

          it { expect { verify }.to raise_error(IndieAuth::TokenVerification::AccessTokenMissingError) }
        end
      end
    end

    context 'due to the DOMAIN environment variable not being set' do
      subject(:verify) { verifier.verify }

      it 'raises the correct error' do
        with_modified_environment(TOKEN_ENDPOINT: token_endpoint_url) do
          expect { verify }.to raise_error(IndieAuth::TokenVerification::MissingDomainError)
        end
      end
    end

    context 'due to no TOKEN_ENDPOINT being defined' do
      subject(:verify) { verifier.verify }

      it 'raises the correct error' do
        with_modified_environment(DOMAIN: domain) do
          expect { verify }.to raise_error(IndieAuth::TokenVerification::MissingTokenEndpointError)
        end
      end
    end

    context 'due to the token endpoint not responding with success' do
      subject(:verify) { verifier.verify }

      let(:response_successful) { false }
      let(:response_body) { nil }

      it 'raises the correct error' do
        with_modified_environment(DOMAIN: domain, TOKEN_ENDPOINT: token_endpoint_url) do
          expect { verify }.to raise_error(IndieAuth::TokenVerification::ForbiddenUserError)
        end
      end
    end

    context 'due to the me value not matching DOMAIN' do
      subject(:verify) { verifier.verify }

      let(:response_body) { "{\"scope\":\"create update delete undelete\",\"me\":\"https://other.example.com/\"}" }

      it 'raises the correct error' do
        with_modified_environment(DOMAIN: domain, TOKEN_ENDPOINT: token_endpoint_url) do
          expect { verify }.to raise_error(IndieAuth::TokenVerification::IncorrectMeError, "Expected: '#{domain}', Received: 'https://other.example.com/'")
        end
      end
    end

    context 'due to the scope requested not being acceptable' do
      subject(:verify) { verifier.verify('media') }

      it 'raises the correct error' do
        with_modified_environment(DOMAIN: domain, TOKEN_ENDPOINT: token_endpoint_url) do
          expect { verify }.to raise_error(IndieAuth::TokenVerification::InsufficentScopeError)
        end
      end
    end
  end
end
