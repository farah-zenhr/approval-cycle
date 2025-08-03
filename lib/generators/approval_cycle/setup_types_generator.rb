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
        else
          migration_template(
            'setup_types_migration.rb.erb',
            'db/migrate/add_approval_cycle_to_configured_types.rb'
          )
        end

        add_approvable_concern_to_models
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
        (ApprovalCycle.configuration&.approval_cycle_setup_types || {}).keys
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

      def add_approvable_concern_to_models
        say "\nAdding ApprovalCycle::Approvable concern to models...", :blue

        configured_types.each do |type|
          model_name = type.to_s.camelize
          model_file_path = "app/models/#{type}.rb"

          if File.exist?(model_file_path)
            add_concern_to_model(model_file_path, model_name, type)
          else
            say "  ✗ Model file not found: #{model_file_path}", :red
          end
        end
      end

      def add_concern_to_model(model_file_path, model_name, type)
        content = File.read(model_file_path)

        if content.include?("include ApprovalCycle::Approvable")
          say "  ✓ #{model_name} already includes ApprovalCycle::Approvable", :green
          return
        end

        # Find the class definition line
        class_line_match = content.match(/^(\s*)class\s+#{model_name}\s*<.*$/)
        unless class_line_match
          say "  ✗ Could not find class definition for #{model_name}", :red
          return
        end

        # Insert the concern after the class definition
        indent = class_line_match[1]
        concern_line = "#{indent}  include ApprovalCycle::Approvable\n"

        updated_content = content.sub(
          /(^#{Regexp.escape(class_line_match[0])}\n)/,
          "\\1#{concern_line}\n"
        )

        File.write(model_file_path, updated_content)
        say "  ✓ Added ApprovalCycle::Approvable to #{model_name}", :green
      end
    end
  end
end
