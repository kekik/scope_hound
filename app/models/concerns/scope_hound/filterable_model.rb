# frozen_string_literal: true

module ScopeHound
  # Delegates all the filtering methods to the filter_proxy
  module FilterableModel
    extend ActiveSupport::Concern

    def filter_proxy
      raise "
            Model #{name} including FilterableModel concern requires filter_proxy method to be defined.
            Method should return filter proxy class associated to model.
          "
    end

    delegate :filter_by, to: :filter_proxy
  end
end
