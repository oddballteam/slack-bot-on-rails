# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubInstallation, type: :model do
  let(:client) { double('client') }

  subject { installation }

  describe '#access_token' do
    let(:installation) do
      FactoryBot.build(:github_installation, access_token: 'ABC', token_expires_at: expiry)
    end

    context 'unexpired token' do
      let(:expiry) { Time.zone.now.tomorrow }
      its(:access_token) { is_expected.to eq 'ABC' }
      its(:token_expires_at) { is_expected.to eq expiry }
    end

    context 'expired token' do
      let(:expiry) { Time.zone.now.yesterday }
      let(:pem) { Rails.application.credentials.github[:app_pem] }
      let(:response) { FactoryBot.build(:github_access_token) }

      before do
        expect(Octokit::Client).to receive(:new).with(hash_including(:bearer_token)) { client }
        expect(client).to receive(:create_app_installation_access_token).with(
          installation.github_id,
          accept: 'application/vnd.github.machine-man-preview+json'
        ) { response }
        allow(installation).to receive(:save) { true }

        # the mocks below are here to speed up testing by skipping openssl
        # they could probably be `allows`
        expect(OpenSSL::PKey::RSA).to receive(:new).with(pem) { 'testing' }
        expect(JWT).to receive(:encode).with(
          hash_including(:iat, :exp, :iss),
          'testing',
          'RS256'
        )

        installation.access_token
      end

      it { is_expected.to have_received(:save) }
      its(:access_token) { is_expected.to eq response.token }
      its(:token_expires_at) { is_expected.to eq response.expires_at }
    end
  end

  describe '#close_issue' do
    let(:github_issue) { FactoryBot.build(:github_issue, :closed) }
    let(:installation) { FactoryBot.build(:github_installation, :access_token) }

    subject do
      installation.close_issue(issue_number: 1234)
    end

    before do
      expect(Octokit::Client).to receive(:new).with(access_token: installation.access_token) { client }
      expect(client).to receive(:close_issue).with(installation.repository, 1234) { github_issue }
    end

    it { is_expected.to eq github_issue }
  end

  describe '#create_issue' do
    let(:github_issue) { FactoryBot.build(:github_issue) }
    let(:installation) { FactoryBot.build(:github_installation, :access_token) }

    subject do
      installation.create_issue(title: 'Updated Docs', body: 'Added some extra links', labels: ['chickens'])
    end

    before do
      expect(Octokit::Client).to receive(:new).with(access_token: installation.access_token) { client }
      expect(client).to receive(:create_issue).with(
        installation.repository,
        'Updated Docs',
        'Added some extra links',
        labels: ['chickens']
      ) {
        github_issue
      }
    end

    it { is_expected.to eq github_issue }
  end

  describe '#label_issue' do
    let(:github_issue) { FactoryBot.build(:github_issue) }
    let(:installation) { FactoryBot.build(:github_installation, :access_token) }
    let(:labels) { %w[one two three] }

    subject do
      installation.label_issue(issue_number: 1234, labels: labels)
    end

    before do
      expect(Octokit::Client).to receive(:new).with(access_token: installation.access_token) { client }
      expect(client).to receive(:update_issue).with(installation.repository, 1234, labels: labels) { github_issue }
    end

    it { is_expected.to eq github_issue }
  end

  describe '#link_issue' do
    let(:description) do
      ApplicationController.render(
        template: 'issues/description.md',
        layout: nil,
        locals: {slack_thread: slack_thread}
      )
    end
    let(:github_issue) { FactoryBot.build(:github_issue) }
    let(:installation) { FactoryBot.build(:github_installation, :access_token) }
    let(:links) { %w[https://f1337.github.io https://github.com] }
    let(:slack_thread) { FactoryBot.build_stubbed(:slack_thread, :links, :issue) }

    subject do
      installation.link_issue(slack_thread)
    end

    before do
      expect(Octokit::Client).to receive(:new).with(access_token: installation.access_token) { client }
      expect(client).to receive(:update_issue).with(
        installation.repository,
        slack_thread.issue_number,
        body: description
      ) {
        github_issue
      }
    end

    it { is_expected.to eq github_issue }
  end
end
