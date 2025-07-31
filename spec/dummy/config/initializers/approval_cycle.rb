ApprovalCycle.configure do |config|
  # Define your approval cycle types here
  # Each type should have a unique integer value
  # Example:
  # config.approval_cycle_setup_types = {
  #   purchase_order: 0,
  #   expense_report: 1,
  #   document_approval: 2
  # }

  config.approval_cycle_setup_types = {
    # Add your approvable models here
    # model_name: integer_value
    dummy_request: 0
  }

  # Customize approval statuses (optional)
  # If not specified, default statuses will be used:
  # pending, rejected, approved, skipped, auto_approved, skipped_after_rejection, skipped_after_withdrawal
  # Example:
  # config.approval_statuses = {
  #   pending: "pending",
  #   approved: "approved",
  #   rejected: "rejected",
  #   cancelled: "cancelled",
  #   on_hold: "on_hold"
  # }
  config.approval_statuses = {
    pending:                  'pending',
    approved:                 'approved',
    rejected:                 'rejected',
    cancelled:                'cancelled',
    on_hold:                  'on_hold',
    auto_approved:            'auto_approved',
    skipped_after_rejection:  'skipped_after_rejection',
    skipped_after_withdrawal: 'skipped_after_withdrawal'
  }
end
