# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubInstallation, type: :model do
  let(:client) { double('client') }
  let(:installation) { FactoryBot.build(:github_installation, :access_token) }
  let(:issue) { FactoryBot.build(:github_issue) }

  before do
    expect(GithubInstallation).to receive(:last) { installation }
    expect(Octokit::Client).to receive(:new).with(access_token: installation.access_token) { client }
  end

  describe '#close' do
    let(:issue) { FactoryBot.build(:github_issue, :closed) }

    subject { issue.close }

    before do
      expect(client).to receive(:close_issue).with(installation.repository, issue.number) { issue }
    end

    it { is_expected.to eq issue }
  end

  # describe '#create_issue' do
  #   subject do
  #     installation.create_issue(title: 'Updated Docs', body: 'Added some extra links', labels: ['chickens'])
  #   end

  #   before do
  #     expect(client).to receive(:create_issue).with(
  #       installation.repository,
  #       'Updated Docs',
  #       'Added some extra links',
  #       labels: ['chickens']
  #     ) {
  #       github_issue
  #     }
  #   end

  #   it { is_expected.to eq github_issue }
  # end

  describe '#labels=' do
    let(:labels) { %w[one two three] }

    subject { issue.labels }

    before do
      expect(client).to receive(:update_issue).with(installation.repository, issue.number, labels: labels) { issue }
      issue.labels = labels
    end

    it { is_expected.to eq labels }
  end

  describe '#title=' do
    let(:title) { 'ID.me testing account help' }

    subject { issue.title }

    before do
      expect(client).to receive(:update_issue).with(installation.repository, issue.number, title: title) { issue }
      issue.title = title
    end

    it { is_expected.to eq title }
  end
end
