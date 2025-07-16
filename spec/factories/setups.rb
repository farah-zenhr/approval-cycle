FactoryBot.define do
  factory :setup, class: 'ApprovalCycle::Setup' do
    name { 'Setup 1' }
    skip_after { 2 }
  end
end
