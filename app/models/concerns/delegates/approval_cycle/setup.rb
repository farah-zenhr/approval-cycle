module Delegates::ApprovalCycle::Setup
  extend ActiveSupport::Concern

  included do
    delegate :created_by, to: :approval_cycle_object_activity
    delegate :updated_by, to: :approval_cycle_object_activity, allow_nil: true
  end
end
