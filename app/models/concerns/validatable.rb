module Validatable
  extend ActiveSupport::Concern

  included do
    send(:include, "Validators::#{name}".constantize)
  end
end
