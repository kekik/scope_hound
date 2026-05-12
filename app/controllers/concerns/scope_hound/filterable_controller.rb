# frozen_string_literal: true

# This module provides an interface for attaching easy filtering capabilities to a controller.
# It acts as a base for models to interact with their controllers. When included in a model,
# it allows the controller to accept a specific set of filter parameters which are then processed
# and applied on the model's data for tailored querying and data selection.
# This is particularly useful when you want to have the flexibility of filtering
# model data directly from controller parameters.
module ScopeHound
  # Adds capability of filtering to the controllers
  module FilterableController
    extend ActiveSupport::Concern
    attr_accessor :all_filtered_records, :unique_filters

    def filter(scope, filters = filter_params)
      filtered_scope, unique_filters = scope.filter_by(**filters)
      self.unique_filters = unique_filters
      self.all_filtered_records = filtered_scope
      filtered_scope
    rescue NoMethodError
      raise "
          Controller #{self.class.name} tried to filter a scope of type #{scope.class.name}.
          Scope class does not extend FilterProxy interface.
        "
    end

    def filter_params
      raise "FilterableModel controller #{self.class.name} does not define filter_params method."
    end

    def filter_values(attribute, all_values, show_all: false)
      if show_all
        all_values
      else
        all_values.select do |_, id|
          unique_filters[attribute]&.include?(id)
        end
      end
    end

    included do
      helper_method :filter_params, :filter_values, :all_filtered_records
    end

    private

    def get_attribute_and_associations(attr_name)
      attribute_parts = attr_name.to_s.split(".")
      field = attribute_parts.pop
      associations = attribute_parts

      [associations, field]
    end
  end
end
