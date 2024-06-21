# Uberloader

Uberloader is an EXPERIMENT for brining [OccamsRecord-style](https://github.com/jhollinger/occams-record/?tab=readme-ov-file#advanced-eager-loading) preloading directly to ActiveRecord.

Nested preloading is accomplished using blocks. Custom scopes may be given as args and/or as method calls inside a block.

```ruby
widgets = Widget.all.
  uberload(:category).
  uberload(:parts, Part.order(:name)) do |u|
    u.uberload(:manufacturer)
    u.uberload(:subparts) do
      u.scope my_subparts_scope_helper

      u.uberload(:foo) do
        u.uberload(:bar)
      end
    end
  end
```
