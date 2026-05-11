# Integration Pattern

[Back to overview](Using-Scope-Hound.md)

## 1. Extend the model

Your model should expose a filter proxy class.

```ruby
class Post < ApplicationRecord
  extend ScopeHound::FilterableModel

  class << self
    def filter_proxy = Filters::PostFilterProxy
  end
end
```

`FilterableModel` delegates `filter_by` to the class returned by `filter_proxy`.

## 2. Define filter scopes in a module

Filter scopes live in a dedicated module that extends `ScopeHound::FilterScopable`.

```ruby
module Filters
  module PostFilterScopes
    extend ScopeHound::FilterScopable

    filter_scope :status, ->(value) { where(status: value) }
    filter_scope :category_id, ->(value) { where(category_id: value) }
    filter_scope :author_id, ->(value) { where(author_id: value) }

    filter_scope :tag_ids, lambda { |ids|
      joins(:tags).where(tags: { id: Array(ids) }).distinct
    }

    filter_scope_path_for :status
    filter_scope_path_for :category_id
    filter_scope_path_for :author_id
    filter_scope_path_for :tag_ids, "tags.id"
  end
end
```

A few details matter here:

- `filter_scope` expects a name and a callable object such as a lambda.
- blank filter values are ignored automatically.
- `filter_scope_path_for` registers which column path should be used when ScopeHound computes unique values for filter UIs.

## 3. Create the filter proxy

The proxy ties the model and the filter scope module together.

```ruby
module Filters
  class PostFilterProxy < ScopeHound::FilterProxy
    def self.query_scope = Post
    def self.filter_scopes_module = Filters::PostFilterScopes
  end
end
```

`query_scope` is the relation ScopeHound starts from. In simple cases this is the model class. In more advanced setups, you can return a preconfigured relation.

## What `filter_by` returns

Calling `filter_by` directly returns two values:

```ruby
filtered_scope, unique_values = Post.filter_by(status: "published")
```

`filtered_scope` is the final relation after all filter scopes run.

`unique_values` is a hash keyed by filter name, containing the distinct values found in the filtered result set for every registered `filter_scope_path_for`.

Example:

```ruby
{
  status: ["draft", "published"],
  category_id: [1, 2, 4],
  author_id: [7, 8]
}
```

That second value is what makes ScopeHound useful for building dynamic filter sidebars.

Next: [Controller and View Usage](Controller-and-View-Usage.md)
