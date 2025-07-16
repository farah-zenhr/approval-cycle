RSpec.describe DummyRequest, type: :model do
  let(:company)     { create(:company) }
  let(:user)        { create(:dummy_user) }
  let(:second_user) { create(:dummy_user) }
  let(:approvers)   { [ { user_id: user.id, order: 0, user_type: 'DummyUser' }, { user_id: second_user.id, order: 1, user_type: 'DummyUser' } ] }
  let!(:setup)      { create(:setup, level: company, modifier: user, **setup_attrs) }
  let(:setup_attrs) { { approval_cycle_approvers_attributes: approvers, approval_cycle_watchers_attributes: [ { user_id: user.id, action: 'both', user_type: 'DummyUser' } ], approval_cycle_action_takers_attributes: [ { user_id: user.id, user_type: 'DummyUser' } ] } }

  subject { create(:dummy_request, approval_cycle_status: :pending, modifier: user, approval_cycle_setup: setup) }

  describe 'Associations' do
    it { is_expected.to belong_to(:approval_cycle_setup) }
    it { is_expected.to have_one(:approval_cycle_object_activity) }
    it { is_expected.to have_many(:approval_cycle_approvals).dependent(:destroy) }
  end

  describe 'Enums' do
    it { should define_enum_for(:approval_cycle_status).with_values({ draft: 0, pending: 1, approved: 2, rejected: 3, withdrawn: 4 }).with_prefix(true) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:approval_cycle_status) }
  end

  describe 'Delegations' do
    it { is_expected.to delegate_method(:created_by).to(:approval_cycle_object_activity) }
  end

  describe '#create_object_activity_log' do
    it 'creates a new activity and associates it to the job_requisition' do
      expect(subject.approval_cycle_object_activity.created_by).to eq(user)
    end
  end

  describe '#callbacks' do
    let(:dummy_request)           { create(:dummy_request, approval_cycle_status: dummy_request_status, modifier: user, approval_cycle_setup: setup) }
    let(:dummy_request_status)    { :pending }
    let(:dummy_request_approvals) { dummy_request.approval_cycle_approvals }

    before { dummy_request }

    context 'create_approvals' do
      context 'when creating dummy_request' do
        context 'when status is pending' do
          it 'creates approvals for each approver in the approval cycle setup' do
            expect(dummy_request_approvals.count).to eq(2)
            expect(dummy_request_approvals.map { |approval| approval.approval_cycle_approver.user_id }).to match_array([ user.id, second_user.id ])
          end
        end

        context 'when status is NOT pending' do
          let(:dummy_request_status) { :draft }

          it 'when creating job_requisition with pending status' do
            expect(dummy_request_approvals.count).to eq(0)
          end
        end
      end

      context 'when updating dummy_request' do
        context 'when updating dummy_request status from draft to pending' do
          let(:dummy_request_status) { :draft }

          before { dummy_request.update(approval_cycle_status: :pending) }

          it 'creates approvals for each approver in the approval cycle setup' do
            expect(dummy_request_approvals.count).to eq(2)
            expect(dummy_request_approvals.map { |approval| approval.approval_cycle_approver.user_id }).to match([ user.id, second_user.id ])
          end
        end

        context 'when updating dummy_request status NOT from draft to pending' do
          let(:dummy_request_status) { :draft }

          before { dummy_request.update(approval_cycle_status: :rejected) }

          it 'when creating dummy_request with pending status' do
            expect(dummy_request_approvals.count).to eq(0)
          end
        end
      end
    end

    context '#link_to_approval_cycle_setup' do
      context 'when dummy_request is to use a new version' do
        let(:new_setup) { create(:setup, level: company, modifier: user, **setup_attrs) }

        context 'when status is not draft' do
          before do
            dummy_request.update(approval_cycle_status: :pending, new_approval_cycle_setup_version: new_setup)
            dummy_request.reload
          end

          it 'does not link dummy_request to the new_approval_cycle_setup_version' do
            expect(dummy_request.approval_cycle_setup).to eq(setup)
          end
        end

        context 'when status is draft' do
          before do
            dummy_request.update(name: 'Test', new_approval_cycle_setup_version: new_setup, approval_cycle_status: :draft)
            dummy_request.reload
          end

          it 'does not link dummy_request to the new_approval_cycle_setup_version' do
            expect(dummy_request.approval_cycle_setup).to eq(new_setup)
          end
        end
      end
    end
  end

  describe '#resync_approval_cycle!' do
    let(:attributes) { setup_attrs }
    let(:new_setup)  { create(:setup, level: company, modifier: user, **attributes) }

    before { subject.new_approval_cycle_setup_version = new_approval_cycle_setup_version }

    context 'when not allowed_to_resync_approval_cycle?' do
      context 'when called outside the context of ApprovalCycleUpdater' do
        let(:new_approval_cycle_setup_version) { setup }

        it 'raises an error' do
          expect { subject.resync_approval_cycle! }.to raise_error(RuntimeError, 'resync_approval_cycle! should only be called within the context of ApprovalCycle::SetupUpdater')
        end
      end

      context 'when called within the context of ApprovalCycleUpdater' do
        before { allow(subject).to receive(:caller).and_return([ 'setup_updater' ]) }

        context 'when new_approval_cycle_setup_version is nil' do
          let(:new_approval_cycle_setup_version) { nil }

          it 'does not resync the approval cycle' do
            expect(subject.resync_approval_cycle!).to be_nil
          end
        end
      end
    end

    context 'when allowed_to_resync_approval_cycle?' do
      let(:new_approval_cycle_setup_version) { new_setup }

      before do
        allow(subject).to receive(:caller).and_return([ 'setup_updater' ])
        subject.resync_approval_cycle!
      end

      context 'when approvers changed' do
        let(:attributes) { setup_attrs.merge(approval_cycle_approvers_attributes: [ approvers.first ], latest_setup_version_id: setup.id) }

        it 'resyncs the approval cycle' do
          expect(subject.is_approval_cycle_reset).to        be_truthy
          expect(subject.approval_cycle_approvals.count).to eq(1)
          expect(subject.approval_cycle_setup).to           eq(new_setup)
        end
      end

      context 'when approvers have NOT changed' do
        let(:attributes) { setup_attrs.merge(latest_setup_version_id: setup.id) }

        it 'resyncs the approval cycle' do
          expect(subject.is_approval_cycle_reset).to be_falsey
          expect(subject.approval_cycle_approvals.count).to eq(2)
          expect(subject.approval_cycle_setup).to eq(new_setup)
          expect(subject.approval_cycle_approvals.pluck(:approval_cycle_approver_id)).to match(new_setup.approval_cycle_approvers.pluck(:id))
        end
      end
    end
  end

  describe '#resync_approval_cycle!' do
    let(:attributes) { setup_attrs }
    let(:new_setup)  { create(:setup, level: company, modifier: user, **attributes) }

    before { subject.new_approval_cycle_setup_version = new_approval_cycle_setup_version }

    context 'when not allowed_to_resync_approval_cycle?' do
      context 'when called outside the context of ApprovalCycleUpdater' do
        let(:new_approval_cycle_setup_version) { setup }

        it 'raises an error' do
          expect { subject.resync_approval_cycle! }.to raise_error(RuntimeError, 'resync_approval_cycle! should only be called within the context of ApprovalCycle::SetupUpdater')
        end
      end

      context 'when called within the context of ApprovalCycleUpdater' do
        before { allow(subject).to receive(:caller).and_return([ 'setup_updater' ]) }

        context 'when new_approval_cycle_setup_version is nil' do
          let(:new_approval_cycle_setup_version) { nil }

          it 'does not resync the approval cycle' do
            expect(subject.resync_approval_cycle!).to be_nil
          end
        end
      end
    end

    context 'when allowed_to_resync_approval_cycle?' do
      let(:new_approval_cycle_setup_version) { new_setup }

      before do
        allow(subject).to receive(:caller).and_return([ 'setup_updater' ])
        subject.resync_approval_cycle!
      end

      context 'when approvers changed' do
        let(:attributes) { setup_attrs.merge(approval_cycle_approvers_attributes: [ approvers.first ], latest_setup_version_id: setup.id) }

        it 'resyncs the approval cycle' do
          expect(subject.is_approval_cycle_reset).to        be_truthy
          expect(subject.approval_cycle_approvals.count).to eq(1)
          expect(subject.approval_cycle_setup).to           eq(new_setup)
        end
      end

      context 'when approvers have NOT changed' do
        let(:attributes) { setup_attrs.merge(latest_setup_version_id: setup.id) }

        it 'resyncs the approval cycle' do
          expect(subject.is_approval_cycle_reset).to                                     be_falsey
          expect(subject.approval_cycle_approvals.count).to                              eq(2)
          expect(subject.approval_cycle_setup).to                                        eq(new_setup)
          expect(subject.approval_cycle_approvals.pluck(:approval_cycle_approver_id)).to match(new_setup.approval_cycle_approvers.pluck(:id))
        end
      end
    end
  end

  describe '#withdraw!' do
    before { subject.withdraw! }

    it 'withdraws the dummy_request' do
      expect(subject.reload.approval_cycle_status).to eq('withdrawn')
    end

    it 'updates the approval status to skipped_after_withdrawal' do
      expect(subject.approval_cycle_approvals.last.status).to eq('skipped_after_withdrawal')
    end
  end

  describe '#approve!' do
    before { subject.approve! }

    it 'approves the dummy_request' do
      expect(subject.reload.approval_cycle_status).to eq('approved')
    end
  end

  describe '#reject!' do
    before { subject.reject! }

    it 'rejects the dummy_request' do
      expect(subject.reload.approval_cycle_status).to eq('rejected')
    end
  end
end
