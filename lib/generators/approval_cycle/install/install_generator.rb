require 'rails/generators'

module ApprovalCycle
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      desc 'Create ApprovalCycle initializer and copy migrations'

      def copy_initializer
        template 'approval_cycle.rb', 'config/initializers/approval_cycle.rb'
      end

      def copy_migrations
        say 'Copying migrations...', :green

        # Get all migration files from the engine
        migration_files = Dir[File.join(ApprovalCycle::Engine.root, 'db', 'migrate', '*.rb')]

        migration_files.each_with_index do |file, index|
          # Extract the migration name (without timestamp)
          basename = File.basename(file)
          migration_name = basename.gsub(/^\d+_/, '')

          # Generate a new unique timestamp with a small delay between each
          new_timestamp = (Time.now + index.seconds).utc.strftime('%Y%m%d%H%M%S')
          new_filename = "#{new_timestamp}_#{migration_name}"

          # Check if migration already exists
          existing = Dir[Rails.root.join('db', 'migrate', "*_#{migration_name}")].first

          if existing
            say "  Migration already exists: #{File.basename(existing)}", :yellow
          else
            FileUtils.cp(file, Rails.root.join('db', 'migrate', new_filename))
            say "  Created migration: #{new_filename}", :green
          end
        end
      end

      def show_readme
        say "\nApprovalCycle installation complete!", :green
        say '=' * 50
        
        # Check for Ruby 3.3 + Rails 7.0 compatibility issue
        if RUBY_VERSION >= '3.3.0' && Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR == 0
          say 'IMPORTANT: Ruby 3.3 + Rails 7.0 Compatibility:', :red
          say 'If you encounter Logger errors, add this to the TOP of config/application.rb:', :yellow
          say 'BEFORE the "Bundler.require" line:', :yellow
          say ''
          say '# Ruby 3.3 + Rails 7.0 compatibility fix'
          say 'require "logger" if RUBY_VERSION >= "3.3.0"'
          say ''
          say '=' * 50
        end
        
        say 'Next steps:', :bold
        say '1. Configure your approval types in config/initializers/approval_cycle.rb'
        say "2. Run 'rails db:migrate' to create the approval cycle tables"
        say "3. Run 'rails generate approval_cycle:setup_types --status' to check your models"
        say "4. Run 'rails generate approval_cycle:setup_types' to add columns to your models"
        say '5. Include ApprovalCycle::Approvable in your models'
        say '=' * 50
      end
    end
  end
end
