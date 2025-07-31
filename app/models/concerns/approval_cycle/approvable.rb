module ApprovalCycle::Approvable
  extend ActiveSupport::Concern

  included do
    include ApprovalCycle::ActsAsTrackable
    acts_as_trackable

    belongs_to :approval_cycle_setup, class_name: 'ApprovalCycle::Setup', foreign_key: 'approval_cycle_setup_id'
    has_many   :approval_cycle_approvers, through: :approval_cycle_setup, class_name: 'ApprovalCycle::Approver'
    has_many   :approval_cycle_approvals, foreign_key: :approvable_id, dependent: :destroy, class_name: 'ApprovalCycle::Approval'

    before_validation :link_to_approval_cycle_setup, on: %i[create update], if: -> { requires_linking_to_approval_cycle_setup? }

    validates_presence_of :approval_cycle_status

    before_create :build_approvals, if: -> { approval_cycle_status_pending? }
    before_update :build_approvals, if: -> { requires_building_approvals? }

    enum approval_cycle_status: { draft: 0, pending: 1, approved: 2, rejected: 3, withdrawn: 4 }, _prefix: true

    delegate :created_by, to: :approval_cycle_object_activity, allow_nil: true
    delegate :updated_by, to: :approval_cycle_object_activity, allow_nil: true

    attr_accessor :new_approval_cycle_setup_version

    def approve!
      update(approval_cycle_status: :approved)
    end

    def reject!
      update(approval_cycle_status: :rejected)
    end

    def withdraw!
      approval_cycle_approvals.where(status: :pending).update_all(status: :skipped_after_withdrawal) if update(approval_cycle_status: :withdrawn)
    end

    def resync_approval_cycle!
      return unless allowed_to_resync_approval_cycle?

      if approvers_changed?
        handle_approvers_changed
      else
        handle_approvers_unchanged
      end

      save
    end

    private

    def link_to_approval_cycle_setup
      self.approval_cycle_setup = new_approval_cycle_setup_version || approval_cycle_setup
    end

    def build_approvals
      approval_cycle_setup.approval_cycle_approvers.each do |approver|
        approval_cycle_approvals.build(
          status:                  ApprovalCycle::Approval.statuses[:pending],
          approvable:              self,
          approval_cycle_approver: approver,
          received_at:             approver.order.zero? ? DateTime.now : nil
        )
      end
    end

    def requires_linking_to_approval_cycle_setup?
      new_record? || approval_cycle_status_draft?
    end

    def requires_building_approvals?
      approval_cycle_status_was == 'draft' && approval_cycle_status_pending?
    end

    def allowed_to_resync_approval_cycle?
      raise 'resync_approval_cycle! should only be called within the context of ApprovalCycle::SetupUpdater' unless caller.any? { |c| c.include?('setup_updater') }

      new_approval_cycle_setup_version.present?
    end

    def approvers_changed?
      new_approval_cycle_setup_version.approval_cycle_approvers.pluck(:user_id, :order, :user_type) != approval_cycle_setup.approval_cycle_approvers.pluck(:user_id, :order, :user_type)
    end

    def handle_approvers_changed
      approval_cycle_approvals.destroy_all
      link_to_approval_cycle_setup
      build_approvals
      self.is_approval_cycle_reset = true
    end

    def handle_approvers_unchanged
      resync_approvals
      link_to_approval_cycle_setup
    end

    def resync_approvals
      approver_mapping = approval_cycle_setup.approval_cycle_approvers.ids.zip(new_approval_cycle_setup_version.approval_cycle_approvers.ids).to_h

      approval_cycle_approvals.each { |approval| approval.update(approval_cycle_approver_id: approver_mapping[approval.approval_cycle_approver_id]) }
    end
  end
end
