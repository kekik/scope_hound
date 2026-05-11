# Using ScopeHound

`scope_hound` gives Rails apps a structured filtering layer built from concerns and a filter proxy. This wiki is split into separate pages so setup, usage, and optimization guidance are easier to navigate.

## Wiki Pages

- [Overview](Using-Scope-Hound.md)
- [Integration Pattern](Integration-Pattern.md)
- [Controller and View Usage](Controller-and-View-Usage.md)
- [Performance and Filter Design](Performance-and-Filter-Design.md)
- [Testing and Adoption](Testing-and-Adoption.md)

## What ScopeHound Does

ScopeHound separates filtering into three responsibilities:

- `ScopeHound::FilterableModel` adds a `filter_by` entry point to a model.
- `ScopeHound::FilterProxy` applies named filter scopes to a base relation.
- `ScopeHound::FilterableController` turns controller params into a filtered relation and exposes helper methods for the view layer.

In practice, the flow is:

1. The controller builds a filter hash from request params.
2. The model delegates `filter_by` to its filter proxy.
3. The proxy extends the relation with filter methods and applies each present filter.
4. The proxy also calculates the unique values still available in the filtered result set.

That makes it useful for pages with:

- sidebar filters
- faceted search
- admin indexes
- reporting screens

## Start Here

If you are new to the gem, read the pages in this order:

1. [Integration Pattern](Integration-Pattern.md)
2. [Controller and View Usage](Controller-and-View-Usage.md)
3. [Performance and Filter Design](Performance-and-Filter-Design.md)
4. [Testing and Adoption](Testing-and-Adoption.md)
