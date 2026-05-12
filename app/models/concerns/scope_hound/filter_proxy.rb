# frozen_string_literal: true

module ScopeHound
  # Supports the filter by methods. And runs the filter methods to get the result query
  class FilterProxy
    extend ScopeHound::FilterScopable

    class << self
      # Model Class whose scope will be extended with our filter scopes module
      def query_scope
        raise "Class #{name} does not define query_scope class method."
      end

      def filter_scopes_module
        raise "Class #{name} does not define filter_scopes_module class method."
      end

      def filter_by(**filters)
        # extend model class scope with filter methods
        extended_scope = query_scope.extending(filter_scopes_module)

        filters.each do |filter_scope, filter_value|
          if filter_value.present? && extended_scope.respond_to?(filter_scope)
            extended_scope = extended_scope.public_send(filter_scope, filter_value)
          end
        end

        unique_filter_values = calculate_unique_filter_values(extended_scope)

        [extended_scope, unique_filter_values]
      end

      def calculate_unique_filter_values(scope)
        filter_scopes_module.filter_scopes_paths.each_with_object({}) do |(filter_scope, path), result|
          result[filter_scope] =
            if path.is_a?(Array)
              path.flat_map { |attribute_path| scope.pluck(attribute_path) }.uniq
            else
              scope.pluck(path).uniq
            end
        end
      end
    end
  end
end
