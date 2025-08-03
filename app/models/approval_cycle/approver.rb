module ApprovalCycle
  class Approver < ApplicationRecord
    include ApprovalCycle::Associatable

    validates :user_id, presence: true, uniqueness: { scope: %i[approval_cycle_setup_id user_type] }
    validates :order,   presence: true, uniqueness: { scope: %i[approval_cycle_setup_id] }
  end
end
