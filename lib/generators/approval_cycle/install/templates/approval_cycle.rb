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
  }
end
