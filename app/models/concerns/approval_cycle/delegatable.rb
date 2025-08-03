module ApprovalCycle::Delegatable
  extend ActiveSupport::Concern

  included do
    send(:include, "Delegates::#{name}".constantize)
  end
end
