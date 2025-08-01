module Associations::ApprovalCycle::ActionTaker
  extend ActiveSupport::Concern

  included do
    belongs_to :user, polymorphic: true
    belongs_to :approval_cycle_setup, class_name: "ApprovalCycle::Setup", foreign_key: "approval_cycle_setup_id", inverse_of: :approval_cycle_action_takers
  end
end
