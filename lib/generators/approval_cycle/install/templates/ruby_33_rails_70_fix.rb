# Ruby 3.3 + Rails 7.0.x Compatibility Fix
# Place this in config/application.rb BEFORE the Bundler.require line

# Fix for Ruby 3.3.x + Rails 7.0.x logger compatibility issue
if RUBY_VERSION >= '3.3.0'
  begin
    require 'logger'
  rescue LoadError
    # Logger already available
  end

  # Ensure Logger constant is available for ActiveSupport
  require 'logger' unless defined?(::Logger)
end
