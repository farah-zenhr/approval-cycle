# ApprovalCycle
Short description and motivation.

## Usage
How to use my plugin.

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
5. Run the migrations:
  ```bash
  rails db:migrate
  ```
6. Include `ApprovalCycle::Approvable` in your models that require approval workflows:
  ```ruby
  class YourModel < ApplicationRecord
    include ApprovalCycle::Approvable
  end
  ```
7. Approval cycle uses versioning for the approval cycle setups to not mess with old approvable records after updating the setup. To use the versioning, you must update your approval cycle setup with the `SetupUpdater` service:
  ```ruby
  ApprovalCycle::SetupUpdater.call(approval_cycle_setup: your_approval_cycle_setup_record, params: {attributes to update}, apply_to_versions: {true | false})
  ```
  ```
