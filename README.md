# Uberloaderer

Uberloader is an EXPERIMENT for brining [OccamsRecord-style](https://github.com/jhollinger/occams-record/?tab=readme-ov-file#advanced-eager-loading) preloading directly to ActiveRecord.

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
