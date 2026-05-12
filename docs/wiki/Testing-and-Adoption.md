# Testing and Adoption

[Back to overview](Using-Scope-Hound.md)

## Testing advice

Test the proxy and the controller separately.

For proxy tests, verify:

- each filter scope applies the expected SQL behavior
- blank values are ignored
- unique values are computed for the right keys

For controller tests, verify:

- `filter_params` maps request input correctly
- `filter` stores `all_filtered_records`
- `unique_filters` is available to the view layer

## Common pitfalls

- Defining `filter_proxy` on the model but forgetting to inherit from `ScopeHound::FilterProxy`
- Registering filter names in `filter_params` that do not match actual scope methods
- Using expensive pluck paths for sidebar values
- Filtering in Ruby instead of SQL
- Forgetting `distinct` after many-to-many joins
- Eager loading inside every scope instead of centralizing it in `query_scope`

## Suggested adoption strategy

If you are adding ScopeHound to an existing Rails app, start small:

1. Move one index page to a filter proxy.
2. Extract two or three filters into `filter_scope` methods.
3. Register only the facet values you truly need.
4. Add eager loading in `query_scope` once the page shape is stable.
5. Measure query count before adding more dynamic filters.

That keeps the abstraction useful without turning every listing page into an over-engineered faceted search system.
