# frozen_string_literal: true

RSpec.describe UpdateUsersDetailsJob do
  subject(:user) { FactoryBot.build_stubbed(:user, :team) }

  before do
    expect(User).to receive(:where).with(real_name: nil) { [user] }
    allow(user).to receive(:update_profile_details)
    UpdateUsersDetailsJob.run
  end

  it { is_expected.to have_received(:update_profile_details) }
end
