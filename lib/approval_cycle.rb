# Ruby 3.3+ compatibility - require logger before Rails loads
begin
  require "logger"
rescue LoadError
  # logger gem not available, Rails should handle this
end

require "approval_cycle/version"
require "approval_cycle/engine"
require "approval_cycle/configuration"

module ApprovalCycle
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
