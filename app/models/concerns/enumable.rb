module Enumable
  extend ActiveSupport::Concern

  included do
    send(:include, "Enums::#{name}".constantize)
  end
end
