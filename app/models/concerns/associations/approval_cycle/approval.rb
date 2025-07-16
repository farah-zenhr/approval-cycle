module Associations::ApprovalCycle::Approval
  extend ActiveSupport::Concern

  included do
    belongs_to :approval_cycle_approver, class_name: "ApprovalCycle::Approver", foreign_key: "approval_cycle_approver_id"
    belongs_to :approvable, polymorphic: true
  end
end
