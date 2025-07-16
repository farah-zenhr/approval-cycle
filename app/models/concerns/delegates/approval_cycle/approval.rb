module Delegates::ApprovalCycle::Approval
  extend ActiveSupport::Concern

  included do
    delegate :order, to: :approval_cycle_approver, prefix: true
  end
end
