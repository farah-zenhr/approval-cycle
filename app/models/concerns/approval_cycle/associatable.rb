module ApprovalCycle::Associatable
  extend ActiveSupport::Concern

  included do
    send(:include, "Associations::#{name}".constantize)
  end
end
