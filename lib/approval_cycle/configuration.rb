module ApprovalCycle
  class Configuration
    attr_accessor :approval_cycle_setup_types

    def initialize
      @approval_cycle_setup_types = {}
    end
  end
end
