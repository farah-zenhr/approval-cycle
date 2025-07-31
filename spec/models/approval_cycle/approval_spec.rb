require 'rails_helper'

module ApprovalCycle
  RSpec.describe Approval, type: :model do
    let(:company)       { create(:company) }
    let(:users)         { create_list(:dummy_user, 4) }
    let(:first_user)    { users.first }
    let(:second_user)   { users.second }
    let(:third_user)    { users.third }
    let(:fourth_user)   { users.fourth }
    let(:user)          { create(:dummy_user) }
    let(:approver)      { create(:approver, user_id: user.id, user_type: 'DummyUser', approval_cycle_setup: setup, order: 10) }
    let(:approvers)     { [{ user_id: first_user.id, order: 0, user_type: 'DummyUser' }, { user_id: second_user.id, order: 1, user_type: 'DummyUser' }, { user_id: third_user.id, order: 2, user_type: 'DummyUser' }] }
    let(:setup)         { create(:setup, level: company, approval_cycle_setup_type: :dummy_request, modifier: user, approval_cycle_approvers_attributes: approvers, approval_cycle_watchers_attributes: [{ user_id: user.id, user_type: 'DummyUser', action: 'both' }], approval_cycle_action_takers_attributes: [{ user_id: user.id, user_type: 'DummyUser' }]) }
    let(:second_setup)  { create(:setup, level: company, modifier: user, approval_cycle_setup_type: :dummy_request) }
    let(:dummy_request) { create(:dummy_request, approval_cycle_setup: setup, approval_cycle_status: :pending, modifier: user) }
    let(:subject)       { create(:approval, approval_cycle_approver: approver, approvable: dummy_request) }

    before { dummy_request }

    describe 'Associations' do
      it { is_expected.to belong_to(:approval_cycle_approver) }
      it { is_expected.to belong_to(:approvable) }
    end

    describe 'Delegations' do
      it { should delegate_method(:order).to(:approval_cycle_approver).with_prefix(true) }
    end

    describe 'Enums' do
      it { should define_enum_for(:status).with_values({ pending: 'pending', approved: 'approved', rejected: 'rejected', cancelled: 'cancelled', on_hold: 'on_hold', auto_approved: 'auto_approved', skipped_after_rejection: 'skipped_after_rejection', skipped_after_withdrawal: 'skipped_after_withdrawal' }).backed_by_column_of_type(:string).with_prefix(true) }

      context 'with custom approval statuses' do
        around do |example|
          original_config = ApprovalCycle.configuration
          ApprovalCycle.configuration = ApprovalCycle::Configuration.new
          ApprovalCycle.configure do |config|
            config.approval_cycle_setup_types = { dummy_request: 0 }
            config.approval_statuses = {
              pending:   'pending',
              approved:  'approved',
              rejected:  'rejected',
              cancelled: 'cancelled'
            }
          end

          example.run

          ApprovalCycle.configuration = original_config
        end

        it 'allows custom statuses to be configured' do
          expect(ApprovalCycle.configuration.approval_statuses).to eq({
                                                                        pending:   'pending',
                                                                        approved:  'approved',
                                                                        rejected:  'rejected',
                                                                        cancelled: 'cancelled'
                                                                      })
        end
      end
    end

    describe '#update_next_approval_received_at' do
      context 'when status changed and status is approved' do
        let(:updates_count) { 1 }

        shared_examples :next_approval_received_at do
          it 'updates next approval received_at' do
            expect { current_approval.approve! }.to change { Approval.where.not(received_at: nil).count }.by(updates_count)
          end
        end

        context 'when current approval is first approval', focus: true do
          let(:current_approval) { Approval.first }

          it_behaves_like :next_approval_received_at
        end

        context 'when current approval second approval' do
          let(:current_approval) { Approval.second }

          it_behaves_like :next_approval_received_at
        end

        context 'when current approval last approval' do
          let(:current_approval) { Approval.last }
          let(:updates_count)    { 0 }

          it_behaves_like :next_approval_received_at
        end
      end

      context 'when status changed and status is not approved' do
        let(:current_approval) { Approval.where.not(received_at: nil) }

        before { Approval.first.update(status: :rejected) }

        context 'when current approval is first approval' do
          it 'does not update next approval received_at' do
            expect(current_approval.count).to          eq(1)
            expect(current_approval.pluck(:status)).to eq(['rejected'])
          end
        end
      end
    end

    describe 'After Creating Dummy Request' do
      let(:awaiting_approvals) { Approval.where(received_at: nil) }

      context 'when creating dummy request with approval cycle' do
        it 'creates approvals' do
          expect(Approval.count).to eq(3)
        end

        it 'creates first approval with received_at and status pending the same time dummy request created' do
          expect(Approval.first.received_at).to be_within(3.seconds).of(dummy_request.created_at)
          expect(Approval.first.status).to      eq('pending')
        end

        it 'creates all other approvals with NIL received_at and status' do
          expect(Approval.last(2).pluck(:approval_cycle_approver_id, :received_at, :status)).to match_array(awaiting_approvals.map { |approver| [approver.id, nil, 'pending'] })
        end
      end
    end

    describe '#auto_approve' do
      let(:request_status) { dummy_request.reload.approval_cycle_status }
      let(:approvals)      { dummy_request.approval_cycle_approvals }

      context 'when created_by is approver' do
        context 'when approver is first and only approver' do
          let(:approvers) { [{ user_id: user.id, order: 0, user_type: 'DummyUser' }] }

          it 'approves request' do
            expect(request_status).to         eq('approved')
            expect(approvals.first.status).to eq('auto_approved')
          end
        end

        context 'when approver is last approver' do
          let(:approvers) { [{ user_id: first_user.id, order: 0, user_type: 'DummyUser' }, { user_id: user.id, order: 1, user_type: 'DummyUser' }] }

          before { Approval.first.approve! }

          it 'approves request' do
            expect(request_status).to        eq('approved')
            expect(approvals.last.status).to eq('auto_approved')
          end
        end

        context 'when approver is not last approver' do
          let(:approvers) { [{ user_id: first_user.id, order: 0, user_type: 'DummyUser' }, { user_id: user.id, order: 1, user_type: 'DummyUser' }, { user_id: third_user.id, order: 2, user_type: 'DummyUser' }] }

          before { Approval.first.approve! }

          it 'auto_approves and passes to the next approver' do
            expect(request_status).to             eq('pending')
            expect(approvals.second.status).to    eq('auto_approved')
            expect(approvals.last.received_at).to be_within(3.seconds).of(Time.zone.now)
          end
        end
      end

      context 'when created_by is not approver' do
        let(:approvers) { [{ user_id: first_user.id, order: 0, user_type: 'DummyUser' }] }

        it 'does not auto approve' do
          expect(request_status).to         eq('pending')
          expect(approvals.first.status).to eq('pending')
        end
      end
    end
  end
end
