module ApprovalCycle
  class ApplicationService
    def initialize(options = {}); end

    def self.call(*args, &block)
      new(*args, &block).call
    end
  end
end
