module ApprovalCycle
  class Watcher < ApplicationRecord
    include ApprovalCycle::Associatable
    include ApprovalCycle::Enumable
    include ApprovalCycle::Validatable
  end
end
