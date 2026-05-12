# frozen_string_literal: true

module ScopeHound
  # Delegates all the filtering methods to the filter_proxy
  module FilterableModel
    extend ActiveSupport::Concern

    def filter_proxy
      raise NotImplementedError,
            "#{name} must define .filter_proxy to return its filter proxy class."
    end

    delegate :filter_by, to: :filter_proxy
  end
end
