module Enums::ApprovalCycle::Setup
  extend ActiveSupport::Concern

  included do
    enum approval_cycle_setup_type: ApprovalCycle.configuration.approval_cycle_setup_types, _prefix: true
  end
end
