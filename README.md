# ScopeHound

`scope_hound` is a Rails filtering gem built around three pieces:

- a model concern that exposes `filter_by`
- a filter proxy class that applies filter scopes
- a controller concern that stores the filtered relation and available filter values

The gem is a good fit when you want controller-driven filtering without pushing parameter logic directly into your Active Record models.

## Installation

Add the gem to your application:

```bash
bundle add scope_hound
```

Or install it directly:

```bash
gem install scope_hound
```

## Basic Usage

1. Extend your model with `ScopeHound::FilterableModel`.
2. Create a filter proxy class that inherits from `ScopeHound::FilterProxy`.
3. Define filter scopes in a separate module using `ScopeHound::FilterScopable`.
4. Include `ScopeHound::FilterableController` in your controller and map request params in `filter_params`.

Minimal example:

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  extend ScopeHound::FilterableModel

  class << self
    def filter_proxy = Filters::PostFilterProxy
  end
end
```

```ruby
# app/models/filters/post_filter_proxy.rb
module Filters
  module PostFilterScopes
    extend ScopeHound::FilterScopable

    filter_scope :status, ->(value) { where(status: value) }
    filter_scope :author_id, ->(value) { where(author_id: value) }

    filter_scope_path_for :status
    filter_scope_path_for :author_id
  end

  class PostFilterProxy < ScopeHound::FilterProxy
    def self.query_scope = Post
    def self.filter_scopes_module = Filters::PostFilterScopes
  end
end
```

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include ScopeHound::FilterableController

  def index
    @posts = filter(Post)
  end

  private

  def filter_params
    {
      status: params[:status],
      author_id: params[:author_id]
    }
  end
end
```

## How It Works

`Post.filter_by(status: "published")` delegates to the filter proxy. The proxy:

1. extends the base relation with your filter scope module
2. applies each matching filter method
3. computes unique values for every registered filter path
4. returns `[filtered_scope, unique_filter_values]`

The controller concern wraps this and exposes:

- `all_filtered_records`
- `unique_filters`
- `filter_values(attribute, all_values, show_all: false)`

## Wiki

A fuller wiki-style usage page is available in [docs/wiki/Using-Scope-Hound.md](docs/wiki/Using-Scope-Hound.md).

## Development

After checking out the repo:

```bash
bin/setup
bundle exec rspec
```

You can also use `bin/console` to load the gem in an interactive session.

## Contributing

Bug reports and pull requests are welcome at:

`https://github.com/kekik/scope_hound`

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).
