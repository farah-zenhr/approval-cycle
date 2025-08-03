require 'logger'
require 'approval_cycle/version'
require 'approval_cycle/engine'
require 'approval_cycle/configuration'

module ApprovalCycle
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
