module ApprovalCycle
  RSpec.describe ObjectActivity, type: :model do
    let(:company) { create(:company) }

    describe 'Associations' do
      it { is_expected.to belong_to(:updated_by).optional }
      it { is_expected.to belong_to(:created_by) }
      it { is_expected.to belong_to(:object) }
    end

    describe 'Polymorphic Associations' do
      it { is_expected.to have_db_column(:object_id).of_type(:integer) }
      it { is_expected.to have_db_column(:object_type).of_type(:string) }
      it { is_expected.to have_db_column(:updated_by_id).of_type(:integer) }
      it { is_expected.to have_db_column(:updated_by_type).of_type(:string) }
      it { is_expected.to have_db_column(:created_by_id).of_type(:integer) }
      it { is_expected.to have_db_column(:created_by_type).of_type(:string) }
    end
  end
end
