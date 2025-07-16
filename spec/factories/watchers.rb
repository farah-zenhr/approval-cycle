FactoryBot.define do
  factory :watcher, class: 'ApprovalCycle::watcher' do
    action { ApprovalCycle::Watcher.actions.keys.sample }
  end
end
