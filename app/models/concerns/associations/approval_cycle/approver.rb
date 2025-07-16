module Associations::ApprovalCycle::Approver
  extend ActiveSupport::Concern

  included do
    belongs_to :user, polymorphic: true
    belongs_to :approval_cycle_setup, class_name: "ApprovalCycle::Setup", foreign_key: "approval_cycle_setup_id", inverse_of: :approval_cycle_approvers
    has_many :approval_cycle_approvals, class_name: "ApprovalCycle::Approval", foreign_key: "approval_cycle_approver_id"
  end
end
