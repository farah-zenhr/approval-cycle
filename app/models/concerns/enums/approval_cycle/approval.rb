module Enums::ApprovalCycle::Approval
  extend ActiveSupport::Concern

  included do
    enum status: { pending: "pending", rejected: "rejected", approved: "approved", skipped: "skipped", auto_approved: "auto_approved", skipped_after_rejection: "skipped_after_rejection", skipped_after_withdrawal: "skipped_after_withdrawal" }, _prefix: true
  end
end
