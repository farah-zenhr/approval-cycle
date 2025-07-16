module ApprovalCycle
  RSpec.describe Watcher, type: :model do
    let(:company) { create(:company) }
    let(:setup)   { create(:setup, level: company) }
    let(:user)    { create(:dummy_user) }
    let(:watcher) { create(:watcher, user: user, setup: approval_cycle) }

    describe 'Associations' do
      it { is_expected.to belong_to(:user) }
      it { is_expected.to belong_to(:approval_cycle_setup) }
    end

    describe 'Validations' do
      it { is_expected.to validate_presence_of(:user_id), uniqueness: { scope: %i[approval_cycle_id action user_type] } }
    end
  end
end
