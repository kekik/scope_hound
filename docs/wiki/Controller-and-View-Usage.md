# Controller and View Usage

[Back to overview](Using-Scope-Hound.md)

## Use the controller concern

In the controller, include `ScopeHound::FilterableController`, call `filter`, and define `filter_params`.

```ruby
class PostsController < ApplicationController
  include ScopeHound::FilterableController

  def index
    @posts = filter(Post)
  end

  private

  def filter_params
    {
      status: params[:status],
      category_id: params[:category_id],
      author_id: params[:author_id],
      tag_ids: params[:tag_ids]
    }
  end
end
```

`filter(Post)` returns the filtered relation and also stores:

- `all_filtered_records`
- `unique_filters`

These are exposed as helper methods by the concern.

## View usage

The controller concern includes `filter_values(attribute, all_values, show_all: false)`.

Use it to reduce a full list of selectable values down to only the ones present in the current filtered result.

```ruby
filter_values(:author_id, Author.pluck(:name, :id))
```

If `show_all: true` is passed, the helper returns the full list unchanged.

This is useful when you want:

- dynamic options for most filters
- a complete list for a specific filter regardless of the current result set

## Practical controller pattern

This is a solid default for an index action:

```ruby
class PostsController < ApplicationController
  include ScopeHound::FilterableController

  def index
    @posts = filter(Post).order(created_at: :desc).page(params[:page])
  end

  private

  def filter_params
    params.permit(:status, :category_id, :author_id, tag_ids: []).
      to_h.
      symbolize_keys
  end
end
```

Why this works well:

- filtering stays explicit
- ordering remains controller-owned
- pagination happens after filtering
- parameter whitelisting stays local to the controller

Next: [Performance and Filter Design](Performance-and-Filter-Design.md)
