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

  describe '#thread_ts' do
    its(:thread_ts) { is_expected.to eq event_data['thread_ts'] }

    context 'without thread' do
      let(:event) { FactoryBot.build(:slack_event) }
      its(:thread_ts) { is_expected.to eq event_data['event_ts'] }
    end
  end
end
