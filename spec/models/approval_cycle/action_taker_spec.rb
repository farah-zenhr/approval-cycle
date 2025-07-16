require 'rails_helper'

module ApprovalCycle
  RSpec.describe ActionTaker, type: :model do
    let(:company)      { create(:company) }
    let(:setup)        { create(:approval_cycle, level: company) }
    let(:user)         { create(:user) }
    let(:action_taker) { create(:approval_cycle_action_taker, user_id: user.id, approval_cycle_id: approval_cycle.id) }

    describe 'Associations' do
      it { is_expected.to belong_to(:user) }
      it { is_expected.to belong_to(:approval_cycle_setup) }
    end
    describe 'Validations' do
      it { is_expected.to validate_presence_of(:user_id), uniqueness: { scope: %i[user_type approval_cycle_id] } }
    end
  end
end
