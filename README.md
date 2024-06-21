# Uberloaderer

Uberloader is an EXPERIMENT for brining [OccamsRecord-style](https://github.com/jhollinger/occams-record/?tab=readme-ov-file#advanced-eager-loading) preloading directly to ActiveRecord.

Nested preloading is accomplished using blocks. Custom scopes may be applied as a method arg and/or as method calls inside a block.

## Stand-alone

The initial implementation is completely external to ActiveRecord and returns an array of ActiveRecord objects.

Pros:

* No monkey patches.

Cons:

* Issues preloads overlap with regular AR preloads.
* Always runs last - can't be treated like an ActiveRecord::Relation.

```ruby
widgets = Uberloader.
  query(Widgets.all).
  uberload(:category).
  uberload(:parts, scope: Part.active) do |u|
    u.uberload(:subparts) do
      u.scope my_subparts_scope_helper
      u.uberload(:foo)
    end
  end.
  to_a
```

## Integrated

This is a purely THEORETICAL integrated implementation.

Pros:

* No issues when combined with regular preloads.
* Part of `ActiveRecord::Relation`.

Cons:

* Monkeypatching of `ActiveRecord::Relation` and probably `ActiveRecord::Associations::Preloader`.

```ruby
widgets = Widget.all.
  uberload(:category).
  uberload(:parts, scope: Part.active) do |u|
    u.uberload(:subparts) do
      u.scope my_subparts_scope_helper
      u.uberload(:foo)
    end
  end
```
