require 'rails_helper'

module ApprovalCycle
  RSpec.describe Approver, type: :model do
  let(:company) { create(:company) }
  let(:user)    { create(:dummy_user) }
  let(:setup)   { create(:setup, level: company, modifier: user) }
  subject       { create(:approver, user: user, approval_cycle_setup: setup, order: 1) }

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:approval_cycle_setup) }
    it { is_expected.to have_many(:approval_cycle_approvals) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:approval_cycle_setup_id, :user_type) }
    it { is_expected.to validate_uniqueness_of(:order).scoped_to(:approval_cycle_setup_id) }
  end
  end
end
