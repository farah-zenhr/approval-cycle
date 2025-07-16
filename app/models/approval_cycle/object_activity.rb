module ApprovalCycle
  class ObjectActivity < ApplicationRecord
    self.record_timestamps = false

    include Associatable
  end
end
