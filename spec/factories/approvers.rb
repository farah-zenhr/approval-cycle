FactoryBot.define do
  factory :approver, class: 'ApprovalCycle::Approver' do
    sequence(:order) { |n| n }
  end
end
