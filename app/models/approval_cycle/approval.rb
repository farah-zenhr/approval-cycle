module ApprovalCycle
  class Approval < ApplicationRecord
    include ApprovalCycle::Associatable
    include ApprovalCycle::Delegatable
    include ApprovalCycle::Enumable

    after_commit :auto_approve, on: %i[create update], if: -> { received_at.present? && status_pending? }

    def approve!
      update!(status: :approved)
      process_next_approval
    end

    def reject!
      update!(status: :rejected, rejection_reason: rejection_reason)
      find_next_approvals.update_all(status: :skipped_after_rejection)
      approvable.reject!
    end

    private

    def auto_approve
      return unless approvable.created_by == approval_cycle_approver.user

      update(status: :auto_approved)
      process_next_approval
    end

    def process_next_approval
      next_approval = find_next_approvals.order(:order).first
      next_approval ? next_approval.update(received_at: Time.zone.now) : approvable.approve!
    end

    def find_next_approvals
      approvable.approval_cycle_approvals.joins(:approval_cycle_approver)
                .where(approval_cycle_approver: { order: (approval_cycle_approver.order + 1).. })
    end
  end
end
