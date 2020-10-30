# frozen_string_literal: true

RSpec.describe ShowHelpJob do
  let(:event) { FactoryBot.build_stubbed(:slack_event, :help) }
  let(:help) do
    ApplicationController.render(template: 'slack_thread/help.slack', layout: nil)
  end
  let(:thread) { FactoryBot.build_stubbed(:slack_thread) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    # allow(thread).to receive(:persisted?).and_return(persisted)
    allow(thread).to receive(:post_ephemeral_reply)
    ShowHelpJob.run(event_id: event.id)
  end

  it 'replies with help' do
    expect(thread).to have_received(:post_ephemeral_reply).with(help, 'U061F7AUR')
  end
end
