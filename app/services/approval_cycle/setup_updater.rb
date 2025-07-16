module ApprovalCycle
  class SetupUpdater < ApplicationService
    attr_reader :approval_cycle_setup, :latest_approval_cycle_setup, :params, :apply_to_versions

    def initialize(options = {})
      @approval_cycle_setup = options[:approval_cycle_setup]
      @params               = options[:params]
      @apply_to_versions    = options[:apply_to_versions]
      super
    end

    def call
      update_approval_cycle_setup

      latest_approval_cycle_setup.persisted? ? latest_approval_cycle_setup : handle_update_failure
    end

    private

    def update_approval_cycle_setup
      ActiveRecord::Base.transaction do
        create_latest_approval_cycle_setup
        handle_syncing if apply_to_versions
      end
    end

    def create_latest_approval_cycle_setup
      @latest_approval_cycle_setup = ApprovalCycle::Setup.create(update_params)
    end

    def update_params
      approval_cycle_setup.attributes
                    .except("id", "created_at", "updated_at")
                    .merge(params, latest_setup_version_id: approval_cycle_setup.latest_setup_version_id)
    end

    def handle_syncing
      # These need to be refactored and moved to services when we create the engine
      preloaded_associations.each do |approvable|
        approvable.new_approval_cycle_setup_version = latest_approval_cycle_setup
        raise ActiveRecord::Rollback unless approvable.resync_approval_cycle!
      end
    end

    def preloaded_associations
      statuses = %i[pending draft]
      associations_records = []
      setup_associations = ApprovalCycle.configuration.approval_cycle_setup_types.keys.map(&:to_s).map(&:pluralize)
      setup_associations.each do |association|
        associations_records << approval_cycle_setup.send(association)
                                                    .where(approval_cycle_status: statuses)
      end

      versions_associations_records = setup_associations.flat_map do |association|
        approval_cycle_setup.versions.includes(association.to_sym)
                            .where(association.pluralize.to_sym => { approval_cycle_status: statuses })
                            .flat_map(&association.singularize.to_sym)
      end
      (associations_records + versions_associations_records).flatten
    end

    def handle_update_failure
      approval_cycle_setup.errors.add(:base, "Failed to update and sync approval cycle")
      approval_cycle_setup
    end
  end
end
