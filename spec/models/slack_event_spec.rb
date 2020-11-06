# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SlackEvent, type: :model do
  subject { event }

  let(:event) { FactoryBot.build(:slack_event, :thread) }
  let(:event_data) { event.metadata['event'] }

  describe '#channel' do
    its(:channel) { is_expected.to eq event_data['channel'] }
  end

  describe '#event_time' do
    its(:event_time) { is_expected.to eq event.metadata['event_time'] }
  end

  describe '#event_ts' do
    its(:event_ts) { is_expected.to eq event_data['event_ts'] }
  end

  describe '#team' do
    its(:team) { is_expected.to eq event_data['team'] }
  end

  describe '#text' do
    its(:text) { is_expected.to eq event_data['text'] }
  end

  describe '#thread_ts' do
    its(:thread_ts) { is_expected.to eq event_data['thread_ts'] }

    context 'without thread' do
      let(:event) { FactoryBot.build(:slack_event) }
      its(:thread_ts) { is_expected.to eq event_data['event_ts'] }
    end
  end

  describe '#user' do
    its(:user) { is_expected.to eq event_data['user'] }
  end

  context 'thread commands' do
    before do
      allow(subject).to receive(:enqueue)
      event.enqueue_job
    end

    context 'add category' do
      subject { AddThreadCategoryJob }
      let(:event) { FactoryBot.build(:slack_event, :add_category) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: 'triage') }
    end

    context 'add link' do
      subject { AddThreadLinkJob }
      let(:event) { FactoryBot.build(:slack_event, :add_link) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: 'https://www.example.com') }
    end

    context 'categories' do
      subject { ListThreadCategoriesJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :categories) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: nil) }
    end

    context 'close' do
      subject { ResolveThreadJob }
      let(:event) { FactoryBot.build(:slack_event, :close) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: nil) }
    end

    context 'extraneous spaces' do
      subject { AddThreadLinkJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :extraneous_spaces) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: 'https://www.example.com') }
    end

    context 'halp' do
      subject { ShowHelpJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :halp) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: nil) }
    end

    context 'help' do
      subject { ShowHelpJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :help) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: nil) }
    end

    context 'link' do
      subject { AddThreadLinkJob }
      let(:event) { FactoryBot.build(:slack_event, :link) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: 'https://www.example.com') }
    end

    context 'links' do
      subject { ListThreadLinksJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :links) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: nil) }
    end

    context 'list categories' do
      subject { ListThreadCategoriesJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :list_categories) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: nil) }
    end

    context 'list links' do
      subject { ListThreadLinksJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :list_links) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: nil) }
    end

    context 'remove category' do
      subject { RemoveThreadCategoryJob }
      let(:event) { FactoryBot.build(:slack_event, :remove_category) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: 'triage') }
    end

    context 'remove link' do
      subject { RemoveThreadLinkJob }
      let(:event) { FactoryBot.build(:slack_event, :remove_link) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: 'https://www.test.com') }
    end

    context 'resolve' do
      subject { ResolveThreadJob }
      let(:event) { FactoryBot.build(:slack_event, :resolve) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: nil) }
    end

    context 'title' do
      subject { UpdateIssueTitleJob }
      let(:event) { FactoryBot.build(:slack_event, :title) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: 'Swallowed a bug') }
    end

    context 'track' do
      subject { CreateThreadJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :track) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: nil) }
    end

    context 'unlink' do
      subject { RemoveThreadLinkJob }
      let(:event) { FactoryBot.build(:slack_event, :unlink) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: 'https://www.test.com') }
    end

    context 'unexpected command' do
      subject { ApplicationJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event) }
      it { is_expected.not_to have_received(:enqueue) }
    end
  end
end
