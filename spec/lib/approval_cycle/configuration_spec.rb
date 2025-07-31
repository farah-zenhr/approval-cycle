require 'rails_helper'

module ApprovalCycle
  RSpec.describe Configuration do
    let(:config) { Configuration.new }

    describe '#approval_statuses' do
      it 'has default approval statuses' do
        expect(config.approval_statuses).to eq({
          pending: "pending",
          rejected: "rejected",
          approved: "approved",
          skipped: "skipped",
          auto_approved: "auto_approved",
          skipped_after_rejection: "skipped_after_rejection",
          skipped_after_withdrawal: "skipped_after_withdrawal"
        })
      end

      it 'allows custom approval statuses to be set' do
        custom_statuses = {
          pending: "pending",
          approved: "approved",
          rejected: "rejected",
          cancelled: "cancelled"
        }

        config.approval_statuses = custom_statuses
        expect(config.approval_statuses).to eq(custom_statuses)
      end
    end

    describe '#approval_cycle_setup_types' do
      it 'starts with empty setup types' do
        expect(config.approval_cycle_setup_types).to eq({})
      end

      it 'allows setup types to be set' do
        setup_types = { dummy_request: 0 }
        config.approval_cycle_setup_types = setup_types
        expect(config.approval_cycle_setup_types).to eq(setup_types)
      end
    end
  end

  RSpec.describe 'ApprovalCycle.configure' do
    around do |example|
      original_config = ApprovalCycle.configuration
      example.run
      ApprovalCycle.configuration = original_config
    end

    it 'allows configuration of approval statuses' do
      ApprovalCycle.configure do |config|
        config.approval_statuses = {
          pending: "pending",
          approved: "approved",
          rejected: "rejected",
          cancelled: "cancelled"
        }
      end

      expect(ApprovalCycle.configuration.approval_statuses).to eq({
        pending: "pending",
        approved: "approved",
        rejected: "rejected",
        cancelled: "cancelled"
      })
    end

    it 'allows configuration of setup types' do
      ApprovalCycle.configure do |config|
        config.approval_cycle_setup_types = { dummy_request: 0 }
      end

      expect(ApprovalCycle.configuration.approval_cycle_setup_types).to eq({
        dummy_request: 0
      })
    end
  end
end
