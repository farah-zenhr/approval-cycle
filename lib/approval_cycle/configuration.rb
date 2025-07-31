module ApprovalCycle
  class Configuration
    attr_accessor :approval_cycle_setup_types, :approval_statuses

    def initialize
      @approval_cycle_setup_types = {}
      @approval_statuses = default_approval_statuses
    end

    private

    def default_approval_statuses
      {
        pending:                  'pending',
        rejected:                 'rejected',
        approved:                 'approved',
        skipped:                  'skipped',
        auto_approved:            'auto_approved',
        skipped_after_rejection:  'skipped_after_rejection',
        skipped_after_withdrawal: 'skipped_after_withdrawal'
      }
    end
  end
end
