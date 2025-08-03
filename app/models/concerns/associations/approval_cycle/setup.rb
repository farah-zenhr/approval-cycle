module Associations::ApprovalCycle::Setup
  extend ActiveSupport::Concern

  included do
    belongs_to :level, polymorphic: true
    has_many   :versions, -> { where(latest: false) }, foreign_key: 'latest_setup_version_id', class_name: 'ApprovalCycle::Setup'
    has_many   :approval_cycle_approvers, -> { order(order: :asc) }, dependent: :destroy, class_name: 'ApprovalCycle::Approver', foreign_key: 'approval_cycle_setup_id', inverse_of: :approval_cycle_setup
    has_many   :approval_cycle_action_takers, dependent: :destroy, class_name: 'ApprovalCycle::ActionTaker', foreign_key: 'approval_cycle_setup_id', inverse_of: :approval_cycle_setup
    has_many   :approval_cycle_watchers,      dependent: :destroy, class_name: 'ApprovalCycle::Watcher', foreign_key: 'approval_cycle_setup_id', inverse_of: :approval_cycle_setup

    # Define dynamic associations safely, only if configuration is available
    setup_types = ApprovalCycle.configuration&.approval_cycle_setup_types || {}
    setup_types.each_key { |type| has_many type.to_s.pluralize.to_sym, class_name: type.to_s.classify, foreign_key: 'approval_cycle_setup_id' }
  end
end
