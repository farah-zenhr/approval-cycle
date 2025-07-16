module Validators::ApprovalCycle::Setup
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true
    validates :skip_after, numericality: { only_integer: true, greater_than: 0 }, if: -> { skip_after.present? }
  end
end
