module Enums::ApprovalCycle::Setup
  extend ActiveSupport::Concern

  included do
    # Use safe navigation and provide a default empty hash to avoid loading order issues
    setup_types = ApprovalCycle.configuration&.approval_cycle_setup_types || {}
    enum approval_cycle_setup_type: setup_types, _prefix: true
  end
end
