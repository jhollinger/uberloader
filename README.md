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

## Interaction with preload and includes

When `uberload` is used, `preload` and `includes` are de-duped. The following will result in **one** query for `parts`, ordered by name:

```ruby
widgets = Widget
  .preload(:parts)
  .uberload(:parts, Part.order(:name))
```

## Testing

Testing is fully scripted under the `bin/` directory. Appraisal is used to test against various ActiveRecord versions, and Docker or Podman is used to test against various Ruby versions. The combinations to test are defined in `test/matrix`.

```bash
# Run all tests
bin/testall

# Filter tests
bin/testall ruby-3.3
bin/testall ar-7.1
bin/testall ruby-3.3 ar-7.1

# Run one specific line from test/matrix
bin/test ruby-3.3 ar-7.1 sqlite3

# Run a specific file
bin/test ruby-3.3 ar-7.1 sqlite3 test/uberload_test.rb

# Run a specific test
bin/test ruby-3.3 ar-7.1 sqlite3 N=test_add_preload_values

# Use podman
PODMAN=1 bin/testall
```
