# Uberloader

Uberloader brings [OccamsRecord-style](https://github.com/jhollinger/occams-record/?tab=readme-ov-file#advanced-eager-loading) preloading directly to ActiveRecord.

Nested preloads use blocks. Custom scopes may be given as args and/or as method calls inside a block.

```ruby
widgets = Widget
  .where(category_id: category_ids)
  .uberload(:category)
  .uberload(:parts, Part.order(:name)) do |u|
    u.uberload(:manufacturer)
    u.uberload(:subparts) do
      u.scope my_subparts_scope_helper

      u.uberload(:foo) do
        u.uberload(:bar)
      end
    end
  end
```

## Status

Uberloader is **currently an experiment**, albiet a promising one. The hope is to have a well-tested gem published sometime in Summer 2024.
