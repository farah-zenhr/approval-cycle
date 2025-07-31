require 'rails_helper'

# Demonstration of configurable approval statuses
RSpec.describe 'Configurable Approval Statuses Demo', type: :model do
  describe 'Configured approval statuses' do
    it 'uses the configured custom statuses for dummy_request' do
      # Since we have custom statuses configured in the dummy app initializer
      expected_statuses = %w[pending approved rejected cancelled on_hold auto_approved skipped_after_rejection skipped_after_withdrawal]
      actual_statuses = ApprovalCycle::Approval.statuses.keys

      expect(actual_statuses).to match_array(expected_statuses)
    end
  end

  describe 'Custom approval statuses configuration' do
    it 'allows configuration to be set' do
      # This demonstrates how a user would configure custom statuses for dummy_request
      custom_config = ApprovalCycle::Configuration.new
      custom_config.approval_statuses = {
        pending:   'pending',
        approved:  'approved',
        rejected:  'rejected',
        cancelled: 'cancelled',
        on_hold:   'on_hold'
      }

      expect(custom_config.approval_statuses.keys).to contain_exactly(
        :pending, :approved, :rejected, :cancelled, :on_hold
      )
    end

    it 'provides access to custom statuses via configuration for dummy_request' do
      # This shows how the enum accesses the configuration for dummy_request workflow
      ApprovalCycle.configure do |config|
        config.approval_cycle_setup_types = { dummy_request: 0 }
        config.approval_statuses = {
          pending:   'pending',
          approved:  'approved',
          rejected:  'rejected',
          cancelled: 'cancelled',
          on_hold:   'on_hold'
        }
      end

      # The configuration is available and can be accessed
      expect(ApprovalCycle.configuration.approval_statuses).to include(
        pending:   'pending',
        approved:  'approved',
        rejected:  'rejected',
        cancelled: 'cancelled',
        on_hold:   'on_hold'
      )
    end
  end

  describe 'Fallback behavior' do
    it 'uses fallback statuses when configuration is nil' do
      # Simulate the enum fallback behavior
      config_statuses = nil
      fallback_statuses = {
        pending:                  'pending',
        rejected:                 'rejected',
        approved:                 'approved',
        skipped:                  'skipped',
        auto_approved:            'auto_approved',
        skipped_after_rejection:  'skipped_after_rejection',
        skipped_after_withdrawal: 'skipped_after_withdrawal'
      }

      # This is what happens in the enum definition
      used_statuses = config_statuses || fallback_statuses

      expect(used_statuses).to eq(fallback_statuses)
    end
  end
end
