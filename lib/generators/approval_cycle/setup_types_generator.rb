require 'rails/generators'
require 'rails/generators/active_record'

module ApprovalCycle
  module Generators
    class SetupTypesGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path('templates', __dir__)
      desc 'Generates migration to add approval cycle columns to configured types'

      class_option :status,
                   type: :boolean,
                   default: false,
                   desc: "Show status of approval cycle columns for configured types"

      def run_generator
        if options[:status]
          show_status
        else
          create_migration_file
        end
      end

      private

      def create_migration_file
        if no_changes_needed?
          say "All configured types already have approval cycle columns. No migration needed.", :green
          return
        end

        migration_template(
          'setup_types_migration.rb.erb',
          'db/migrate/add_approval_cycle_to_configured_types.rb'
        )
      end

      def show_status
        say "Approval Cycle Setup Status:", :bold
        say "=" * 50

        configured_types.each do |type|
          table_name = type.to_s.pluralize
          say "\n#{type.to_s.camelize} (#{table_name}):", :blue

          if table_exists?(table_name)
            approval_cycle_columns.each do |column|
              status = column_exists?(table_name, column) ? "✓" : "✗"
              color = column_exists?(table_name, column) ? :green : :red
              say "  #{status} #{column}", color
            end
          else
            say "  ✗ Table does not exist", :red
          end
        end

        say "\n" + "=" * 50
        say "Run 'rails generate approval_cycle:setup_types' to add missing columns"
      end

      def no_changes_needed?
        configured_types.all? do |type|
          table_name = type.to_s.pluralize
          next false unless table_exists?(table_name)

          approval_cycle_columns.all? { |column| column_exists?(table_name, column) }
        end
      end

      def migration_class_name
        'AddApprovalCycleToConfiguredTypes'
      end

      def configured_types
        ApprovalCycle.configuration.approval_cycle_setup_types.keys
      end

      def table_exists?(table_name)
        ActiveRecord::Base.connection.table_exists?(table_name)
      end

      def column_exists?(table_name, column_name)
        ActiveRecord::Base.connection.column_exists?(table_name, column_name)
      end

      def approval_cycle_columns
        %w[approval_cycle_setup_id approval_cycle_status is_approval_cycle_reset]
      end
    end
  end
end
