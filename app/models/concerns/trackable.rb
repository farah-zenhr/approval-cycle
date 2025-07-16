module Trackable
  extend ActiveSupport::Concern

  included do
    attr_accessor :modifier

    has_one :approval_cycle_object_activity, as: :object, dependent: :destroy, class_name: "ApprovalCycle::ObjectActivity"

    after_commit :log_object_activity, on: %i[create update], if: -> { modifier.present? }
  end

  private

  def log_object_activity
    object_activity              = ApprovalCycle::ObjectActivity.find_or_initialize_by(trackable_object)
    object_activity.object_id    = id
    object_activity.created_by ||= modifier

    if object_activity.persisted?
      object_activity.updated_by = modifier
      object_activity.updated_at = Time.current
    end

    object_activity.save!
  end

  def trackable_object
    { object_id: send(self.class.trackable_column), object_type: self.class.name }
  end
end
