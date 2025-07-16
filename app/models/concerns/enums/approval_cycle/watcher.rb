module Enums::ApprovalCycle::Watcher
  extend ActiveSupport::Concern

  included do
    enum action: { approve: 0, reject: 1, both: 2 }, _prefix: true
  end
end
