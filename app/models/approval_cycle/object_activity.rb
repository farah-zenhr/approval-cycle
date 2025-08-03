module ApprovalCycle
  class ObjectActivity < ApplicationRecord
    self.record_timestamps = false

    include ApprovalCycle::Associatable
  end
end
