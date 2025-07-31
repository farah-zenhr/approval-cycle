module ApprovalCycle
  class Setup < ApplicationRecord
    include Associatable
    include Enumable
    include Validatable
    include Delegatable
    include ActsAsTrackable

    acts_as_trackable :latest_setup_version_id

    accepts_nested_attributes_for :approval_cycle_approvers, :approval_cycle_watchers, :approval_cycle_action_takers

    attr_accessor :force_delete

    after_create_commit :update_previous_approval_cycle_versions

    before_create  :set_approvers_order
    before_destroy :delete_previous_versions, prepend: true

    private

    def update_previous_approval_cycle_versions
      # Mark all previous setups for the same level as not latest
      previous_setups = Setup.where(level: level).where.not(id: id)
      previous_setups.update_all(latest: false, latest_setup_version_id: id)

      # Ensure this setup is marked as latest and points to itself
      update_columns(latest: true, latest_setup_version_id: id)
    end

    def set_approvers_order
      approval_cycle_approvers.sort_by(&:order).each_with_index { |approver, index| approver.order = index }
    end

    def delete_previous_versions
      versions.each do |version|
        version.force_delete = true
        version.destroy
      end
    end
  end
end
