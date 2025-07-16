module Validators::ApprovalCycle::ActionTaker
  extend ActiveSupport::Concern
  included do
    validates :user_id, presence: true, uniqueness: { scope: %i[approval_cycle_setup_id user_type] }
  end
end
