# Performance and Filter Design

[Back to overview](Using-Scope-Hound.md)

## Recommended filter design

Keep each filter scope narrow and composable.

Good:

```ruby
filter_scope :status, ->(value) { where(status: value) }
filter_scope :published_after, ->(value) { where("published_at >= ?", value) }
```

Avoid scopes that:

- read controller params directly
- mutate external state
- preload unrelated associations
- perform Ruby-side filtering on loaded records

The proxy expects relation-building methods. Stay inside SQL as long as possible.

## Prefer a scoped base relation in `query_scope`

If every request should start from a common optimized relation, centralize it in the proxy.

```ruby
class PostFilterProxy < ScopeHound::FilterProxy
  def self.query_scope
    Post.published.includes(:author, :category)
  end

  def self.filter_scopes_module = Filters::PostFilterScopes
end
```

This is the right place for eager loading that most filtered pages always need.

Use `includes` when the page will render associated records and you want to avoid N+1 queries.

Use `joins` when the association is only needed for filtering.

Use `preload` if you want eager loading without changing join behavior.

## Eager load deliberately, not everywhere

Do not add `includes` to every individual filter scope unless that scope truly owns the rendering concern. Repeated eager loading inside many scopes makes behavior harder to reason about and can create bloated queries.

Prefer:

- shared eager loading in `query_scope`
- filter-specific joins inside the relevant scope
- controller-level pagination after filtering

## Keep filter scopes SQL-first

Bad:

```ruby
filter_scope :status, ->(value) { select { |post| post.status == value } }
```

Good:

```ruby
filter_scope :status, ->(value) { where(status: value) }
```

Ruby-side filtering forces records into memory and breaks relation chaining.

## Register cheap, indexed paths for unique values

`calculate_unique_filter_values` uses `pluck(...).uniq` for every registered filter path. That means every extra registered path adds query work.

Keep `filter_scope_path_for` focused on values you actually need in the UI.

Prefer:

- indexed columns
- foreign keys
- low-cardinality fields

Be careful with:

- large text fields
- derived values
- expensive join paths

## Reduce expensive association plucks

If you register a path like `"tags.id"` or `"authors.email"`, ScopeHound will pluck through that relation from the current scope. That can be correct, but on large result sets it may become the most expensive part of filtering.

If a filter sidebar does not need live recalculation on every request, consider:

- showing all options with `show_all: true`
- caching the option list elsewhere
- calculating only a subset of filters dynamically

## Use `distinct` when joins multiply rows

When a filter joins a `has_many` or many-to-many relation, the relation may duplicate base rows.

```ruby
filter_scope :tag_ids, lambda { |ids|
  joins(:tags).where(tags: { id: Array(ids) }).distinct
}
```

Without `distinct`, both the result set and the unique-value calculations may behave unexpectedly.

## Paginate after filtering

Apply pagination to the filtered relation, not before.

Good:

```ruby
@posts = filter(Post).page(params[:page])
```

This keeps facet values aligned with the filtered dataset.

## Keep class methods deterministic

`query_scope` and other proxy class methods should return stable relations. Avoid request-global state, thread-local assumptions, or hidden side effects.

Good class methods are:

- deterministic
- relation-returning
- easy to test in isolation

## Watch for repeated facet work

ScopeHound currently calculates unique values for every registered filter every time `filter_by` runs. If you register ten filters, you pay for ten distinct-value lookups.

For large tables, start with a small set of dynamic facets and expand only when needed.

Next: [Testing and Adoption](Testing-and-Adoption.md)
