module ApprovalCycle
  RSpec.describe SetupUpdater, type: :service do
    describe '#call' do
      let(:company)            { create(:company) }
      let(:user)               { create(:dummy_user) }
      let(:setup_attrs)        { { approval_cycle_approvers_attributes: [ { user_id: user.id, order: 0, user_type: 'DummyUser' } ], approval_cycle_watchers_attributes: [ { user_id: user.id, action: 'both', user_type: 'DummyUser' } ], approval_cycle_action_takers_attributes: [ { user_id: user.id, user_type: 'DummyUser' } ] } }
      let(:setup)              { create(:setup, level: company, modifier: user) }
      let(:dummy_request)      { create(:dummy_request, approval_cycle_status: :pending, modifier: user, approval_cycle_setup: setup) }
      let(:update_params)      { { name: 'New Name', skip_after: 3, approval_cycle_setup_type: 'dummy_request', **setup_attrs } }
      let(:updated_setup)      { Setup.last }
      let(:apply_to_versions)  { false }

      subject { ApprovalCycle::SetupUpdater.call(approval_cycle_setup: setup, params: params, apply_to_versions: apply_to_versions) }

      before { dummy_request }

      context 'with valid params' do
        context 'when apply_to_versions is false' do
          let(:params) { update_params }

          before { subject }

          it 'updates the approval cycle setup' do
            expect(updated_setup.name).to                               eq('New Name')
            expect(updated_setup.skip_after).to                         eq(3)
            expect(updated_setup.approval_cycle_setup_type).to          eq('dummy_request')
            expect(updated_setup.approval_cycle_approvers.count).to     eq(1)
            expect(updated_setup.approval_cycle_watchers.count).to      eq(1)
            expect(updated_setup.approval_cycle_action_takers.count).to eq(1)
            expect(dummy_request.approval_cycle_approvals.count).to     eq(0)
            expect(dummy_request.approval_cycle_setup).to               eq(setup)
          end
        end

        context 'when apply_to_versions is true' do
          let(:apply_to_versions) { true }
          let(:second_user)       { create(:dummy_user) }
          let(:approvers)         { [ { user_id: user.id, order: 0, user_type: 'DummyUser' }, { user_id: second_user.id, order: 1, user_type: 'DummyUser' } ] }

          context 'when approvers have changed' do
            let(:params) { update_params.merge(approval_cycle_approvers_attributes: approvers) }

            before do
              subject
              dummy_request.reload
            end

            it 'updates the approvals of dummy request belonging to the approval cycle setup' do
              expect(dummy_request.approval_cycle_approvals.count).to eq(2)
              expect(dummy_request.approval_cycle_setup).to           eq(updated_setup)
            end
          end

          context 'when approvers have not changed' do
            let(:params) { update_params.merge(approval_cycle_approvers_attributes: []) }

            before { subject }

            it 'does not update the approvals of dummy request belonging to the approval cycle setup' do
              expect(dummy_request.approval_cycle_approvals.count).to eq(0)
              expect(dummy_request.approval_cycle_setup).to           eq(setup)
            end
          end

          context 'when handling update failure' do
            let(:params) { update_params.merge(approval_cycle_approvers_attributes: approvers) }

            before { allow_any_instance_of(DummyRequest).to receive(:resync_approval_cycle!).and_return(false) }

            it 'returns the approval cycle with an error' do
              expect(subject.errors.messages).to eq(base: [ 'Failed to update and sync approval cycle' ])
            end
          end
        end
      end

      context 'with invalid params' do
        let(:params) { { name: '' } }

        before { subject }

        it 'does not update the approval cycle setup and returns an error' do
          expect(updated_setup.name).not_to eq('')
        end
      end
    end
  end
end
