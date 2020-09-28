# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SlackEvent, type: :model do
  subject { event }

  let(:event) { FactoryBot.build(:slack_event, :thread) }
  let(:event_data) { event.metadata['event'] }

  describe '#channel' do
    its(:channel) { is_expected.to eq event_data['channel'] }
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

    # context 'help' do
    #   let(:event) { FactoryBot.build(:slack_event, :help) }
    #   its(:command) { is_expected.to eq { 'help' => nil } }
    #   its(:job) { is_expected.to eq HelpJob }
    # end

    context 'categories' do
      subject { ListThreadCategoriesJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :categories) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id) }
    end

    context 'list categories' do
      subject { ListThreadCategoriesJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :list_categories) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id) }
    end

    context 'remove category' do
      subject { RemoveThreadCategoryJob }
      let(:event) { FactoryBot.build(:slack_event, :remove_category) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id, options: 'triage') }
    end

    context 'track' do
      subject { CreateThreadJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event, :track) }
      it { is_expected.to have_received(:enqueue).with(event_id: event.id) }
    end

    context 'unexpected command' do
      subject { ApplicationJob }
      let(:event) { FactoryBot.build_stubbed(:slack_event) }
      it { is_expected.not_to have_received(:enqueue) }
    end
  end
end
