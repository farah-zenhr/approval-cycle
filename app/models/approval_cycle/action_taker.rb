module ApprovalCycle
  class ActionTaker < ApplicationRecord
    include ApprovalCycle::Associatable
    include ApprovalCycle::Validatable
  end
end
