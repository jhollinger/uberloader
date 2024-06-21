# Uberloaderer

Uberloader is an EXPERIMENT for brining [OccamsRecord-style](https://github.com/jhollinger/occams-record/?tab=readme-ov-file#advanced-eager-loading) preloading directly to ActiveRecord.

Nested preloading is accomplished using blocks. Custom scopes may be applied as a method arg and/or as method calls inside a block.

## Non-invasive preloader

The initial implementation is completely external to ActiveRecord and returns an array of ActiveRecord objects.

Pros:

* No monkey patches

Cons:

* Issues preloads overlap with regular AR preloads.
* Always runs last - can't be passed to a caller and treated like an ActiveRecord::Relation.

```ruby
widgets = Uberloader.
  query(Widgets.all).
  preload(:category).
  preload(:parts, scope: Part.active) do |u|
    u.preload(:subparts) do
      u.scope my_subparts_scope_helper
      u.preload(:foo)
    end
  end.
  to_a
```
