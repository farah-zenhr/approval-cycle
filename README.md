# ApprovalCycle

ApprovalCycle is a flexible Rails engine that provides a comprehensive approval workflow system for your Rails applications. It allows you to easily add multi-step approval processes to any model, with support for parallel approvals, watchers, action takers, and versioned approval setups.

## Features

- **Multi-step approval workflows** - Define complex approval chains with multiple approvers
- **Polymorphic approvers** - Use any model as an approver (Users, Roles, etc.)
- **Parallel approvals** - Support for approvals that can happen simultaneously
- **Watchers and Action Takers** - Notify stakeholders and define who can take actions
- **Versioned setups** - Update approval workflows without affecting existing requests
- **Flexible configuration** - Easy setup through Rails generators and initializers
- **Status tracking** - Built-in status management (draft, pending, approved, rejected, etc.)

## Usage

Perfect for applications that need approval workflows for:
- Purchase orders and expense reports
- Document approvals and reviews
- User access requests
- Content publishing workflows
- Any business process requiring structured approvals

## Installation

Add this line to your application's Gemfile:

```ruby
gem "approval_cycle"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install approval_cycle
```

### Ruby 3.3 + Rails 7.0 Compatibility

If you're using Ruby 3.3+ with Rails 7.0.x, you may encounter a `Logger` constant error. To fix this, add the following line to the **TOP** of your `config/application.rb` file, **BEFORE** the `Bundler.require` line:

**Simple fix:**
```ruby
# Ruby 3.3 + Rails 7.0 compatibility fix
require "logger" if RUBY_VERSION >= "3.3.0"
```

**Comprehensive fix** (recommended if you encounter persistent issues):
```ruby
# Ruby 3.3 + Rails 7.0.x Compatibility Fix
if RUBY_VERSION >= '3.3.0'
  begin
    require 'logger'
  rescue LoadError
    # Logger already available
  end
  
  # Ensure Logger constant is available for ActiveSupport
  unless defined?(::Logger)
    require 'logger'
  end
end
```

Example placement in `config/application.rb`:
```ruby
require_relative "boot"

# Ruby 3.3 + Rails 7.0 compatibility fix
require "logger" if RUBY_VERSION >= "3.3.0"

require "rails"
# ... rest of your application.rb
```

This fix is automatically suggested when you run `rails generate approval_cycle:install`.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## How to Use

1. Add the gem to your Gemfile:
  ```ruby
  gem 'approval_cycle'
  ```
2. Run `bundle install` to install the gem.
3. Add the initializer file with types (models that you want to be approvable):
  ```bash
  rails generate approval_cycle:install
  ```
4. Customize the generated initializer file (`config/initializers/approval_cycle.rb`) to fit your application's needs. In the initializer, set up the approval cycle types:
  ```ruby
  ApprovalCycle.configure do |config|
    config.approval_cycle_setup_types = { dummy_request: 0 }
  end
  ```

## Configuration Options

### Approval Types
Define which models in your application can have approval workflows:
```ruby
ApprovalCycle.configure do |config|
  config.approval_cycle_setup_types = {
    dummy_request: 0,
    purchase_order: 1,
    expense_report: 2
  }
end
```

### Approval Statuses
Customize the approval statuses available in your application. If not provided, the gem will use the default statuses:
```ruby
ApprovalCycle.configure do |config|
  config.approval_statuses = {
    pending: "pending",
    approved: "approved",
    rejected: "rejected",
    cancelled: "cancelled",
    on_hold: "on_hold"
  }
end
```

**Default statuses**: `pending`, `rejected`, `approved`, `skipped`, `auto_approved`, `skipped_after_rejection`, `skipped_after_withdrawal`
5. Generate migrations for your configured types:
  ```bash
  # Check which columns are missing
  rails generate approval_cycle:setup_types --status

  # Generate migration to add approval cycle columns to your models
  # This will also automatically add ApprovalCycle::Approvable to your model files
  rails generate approval_cycle:setup_types
  ```
6. Run the migrations:
  ```bash
  rails db:migrate
  ```
7. Approval cycle uses versioning for the approval cycle setups to not mess with old approvable records after updating the setup. To use the versioning, you must update your approval cycle setup with the `SetupUpdater` service:
  ```ruby
  ApprovalCycle::SetupUpdater.call(approval_cycle_setup: your_approval_cycle_setup_record, params: {attributes to update}, apply_to_versions: {true | false})
  ```

## Adding New Types

When you need to add new approval types to your application:

1. Update your initializer file (`config/initializers/approval_cycle.rb`) with the new types:
  ```ruby
  ApprovalCycle.configure do |config|
    config.approval_cycle_setup_types = {
      dummy_request: 0,
      new_type: 1  # Add your new type here with the next integer
    }
  end
  ```

2. Check what columns need to be added:
  ```bash
  rails generate approval_cycle:setup_types --status
  ```

3. Generate and run the migration:
  ```bash
  rails generate approval_cycle:setup_types
  rails db:migrate
  ```

Note: The `ApprovalCycle::Approvable` concern will be automatically added to your new model when you run the generator.

## Generator Commands

- `rails generate approval_cycle:install` - Creates the initializer file and copies migrations
- `rails generate approval_cycle:setup_types --status` - Shows which approval cycle columns are missing for configured types
- `rails generate approval_cycle:setup_types` - Generates migration to add missing approval cycle columns to your configured models and automatically adds `ApprovalCycle::Approvable` concern to the model files
