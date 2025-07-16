module ApprovalCycle
  RSpec.describe Setup, type: :model do
    let(:company)              { create(:company) }
    let(:first_user)           { create(:dummy_user, name: 'first user') }
    let(:second_user)          { create(:dummy_user, name: 'second user') }
    let(:third_user)           { create(:dummy_user, name: 'third user') }
    let(:fourth_user)          { create(:dummy_user, name: 'fourth user') }
    let(:first_version_setup)  { create(:approval_cycle, company: company, modifier: first_user, approvers_attributes: approvers, name: 'testing approval cycle', approval_cycle_watchers_attributes: watchers, approval_cycle_action_takers_attributes: action_takers) }
    let(:second_version_setup) { create(:approval_cycle, company: company, modifier: first_user, approvers_attributes: approvers, name: 'testing approval cycle', approval_cycle_watchers_attributes: watchers, approval_cycle_action_takers_attributes: action_takers, latest_setup_version_id: first_version_setup.id) }
    let(:latest_setup)         { create(:approval_cycle, company: company, modifier: second_user, approvers_attributes: approvers, name: 'testing approval cycle', approval_cycle_watchers_attributes: watchers, approval_cycle_action_takers_attributes: action_takers, latest_setup_version_id: second_version_setup.id, created_at: today - 5.days) }
    let(:second_setup)         { create(:approval_cycle, company: company, modifier: fourth_user, approvers_attributes: approvers, name: 'amman approval', approval_cycle_watchers_attributes: watchers, approval_cycle_action_takers_attributes: action_takers, created_at: today - 10.days) }
    let(:third_setup)          { create(:approval_cycle, company: company, modifier: third_user, approvers_attributes: approvers, name: 'barcelona approval', approval_cycle_watchers_attributes: watchers, approval_cycle_action_takers_attributes: action_takers, created_at: today - 1.days) }
    let(:latest_setups)        { Setup.left_joins_object_activities.where_latest_versions(true) }
    let(:approvers)            { [ { user_id: first_user.id, order: 0, user_type: 'DummyUser' } ] }
    let(:watchers)             { [ { user_id: first_user.id, action: 'both', user_type: 'DummyUser' } ] }
    let(:action_takers)        { [ { user_id: first_user.id, user_type: 'DummyUser' } ] }
    let(:today)                { Time.zone.today }

    describe 'Enums' do
      # This is taken by the configuration initializer in the dummy app
      it { should define_enum_for(:approval_cycle_setup_type).with_values({ dummy_request: 0 }).with_prefix(true) }
    end

    describe 'Associations' do
      it { is_expected.to belong_to(:level) }
      it { is_expected.to have_one(:approval_cycle_object_activity).dependent(:destroy) }
      it { is_expected.to have_many(:approval_cycle_approvers).order(order: :asc).dependent(:destroy) }
      it { is_expected.to have_many(:approval_cycle_watchers).dependent(:destroy) }
      it { is_expected.to have_many(:approval_cycle_action_takers).dependent(:destroy) }
      it { is_expected.to have_many(:versions).conditions(latest: false).with_foreign_key('latest_setup_version_id').class_name('ApprovalCycle::Setup') }
      it { is_expected.to have_many(:dummy_requests) }
    end

    describe 'Validations' do
      it { is_expected.to validate_presence_of(:name) }

      context 'when skip_after is present' do
        before { allow(subject).to receive(:skip_after).and_return(5) }

        it { is_expected.to validate_numericality_of(:skip_after).is_greater_than(0) }
      end

      context 'when skip_after is not present' do
        before { allow(subject).to receive(:skip_after).and_return(nil) }

        it { is_expected.not_to validate_numericality_of(:skip_after).is_greater_than(0) }
      end
    end

    describe '#set_approvers_order' do
      let(:setup) do create(:setup, level: company, modifier: first_user, approval_cycle_approvers_attributes: approvers,
         approval_cycle_watchers_attributes: [ { user_id: first_user.id, action: 'both', user_type: 'DummyUser' } ],
          approval_cycle_action_takers_attributes: [ { user_id: first_user.id, user_type: 'DummyUser' } ])
      end
      let(:approvers) { [ { user_id: first_user.id, order: 132, user_type: 'DummyUser' }, { user_id: third_user.id, order: 432, user_type: 'DummyUser' }, { user_id: second_user.id, order: 12, user_type: 'DummyUser' } ] }

      context 'when creating a new approval cycle setup' do
        before { setup }

        it 'sets the order of the approvers from 0 to the count of approvers -1' do
          expect(setup.approval_cycle_approvers.pluck(:order, :user_id)).to match_array([ [ 0, second_user.id ], [ 1, first_user.id ], [ 2, third_user.id ] ])
        end
      end
    end

    describe 'Nested Attributes' do
      it { is_expected.to accept_nested_attributes_for(:approval_cycle_approvers) }
      it { is_expected.to accept_nested_attributes_for(:approval_cycle_watchers) }
      it { is_expected.to accept_nested_attributes_for(:approval_cycle_action_takers) }
    end

    describe 'creating a new version of an approval cycle setup' do
      let(:setup) { create(:setup, level: company, modifier: first_user) }

      context 'when only one version of the approval cycle setup exists' do
        it 'sets the latest_setup_version_id of the approval cycle setup to the id of the new version' do
          expect(setup.latest_setup_version_id).to eq(setup.id)
        end

        it 'sets the computed column latest to true automatically using the database' do
          expect(setup.latest?).to be_truthy
        end
      end

      context 'when multiple versions of the approval cycle setup exist' do
        let(:second_setup) { create(:setup, level: company, latest_setup_version_id: setup.id) }

        before do
          second_setup.reload
          setup.reload
        end

        context '#update_previous_approval_cycle_versions' do
          it 'updates the latest_setup_version_id of the previous versions using the id of the new version' do
            expect(second_setup.latest_setup_version_id).to eq(second_setup.id)
            expect(setup.latest_setup_version_id).to        eq(second_setup.id)
            expect(second_setup.versions).to                eq([ setup ])
          end
        end

        it 'updates the computed column latest of the previous versions automatically using the database' do
          expect(setup.latest?).to        be_falsey
          expect(second_setup.latest?).to be_truthy
        end
      end
    end

    describe '#create_object_activity_log' do
      let(:setup)                { create(:setup, level: company, modifier: first_user) }
      let(:setup_second_version) { create(:setup, level: company, latest_setup_version_id: setup.id, modifier: second_user) }

      context 'when you create the first version of an approval cycle setup' do
        it 'creates a new activity and associates it to the approval_cycle_setup' do
          expect(setup.approval_cycle_object_activity.created_by).to eq(first_user)
          expect(setup.approval_cycle_object_activity.updated_by).to eq(nil)
          expect(setup.approval_cycle_object_activity.updated_at).to eq(nil)
        end
      end

      context 'when creating new version of approval cycle' do
        before { Setup.all.reload }

        it 'updates the object_activity and associates it with the new version' do
          expect(setup_second_version.approval_cycle_object_activity.updated_by).to eq(second_user)
          expect(setup_second_version.approval_cycle_object_activity.updated_at).to be_within(3.seconds).of(DateTime.now)
          expect(setup_second_version.approval_cycle_object_activity.created_by).to eq(first_user)
          expect(setup.reload.approval_cycle_object_activity).to be_nil
        end
      end
    end
  end
end
