module ApprovalCycle
  class Watcher < ApplicationRecord
    include Associatable
    include Enumable
    include Validatable
  end
end
