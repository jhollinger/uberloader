# Uberloader

Uberloader is a new way of preloading associations in ActiveRecord. Nested preloads use blocks. Custom scopes may be given as args and/or as method calls inside a block.

```ruby
widgets = Widget
  .where(category_id: category_ids)
  # Preload category
  .uberload(:category)
  # Preload parts, ordered by name
  .uberload(:parts, scope: Part.order(:name)) do |u|
    # Preload the parts' manufacturer
    u.uberload(:manufacturer)
    # and their subparts, using a custom scope
    u.uberload(:subparts) do
      u.scope my_subparts_scope_helper

      u.uberload(:foo) do
        u.uberload(:bar)
      end
    end
  end
```

## Status

Uberloader is an attempt to bring [ideas from OccamsRecord](https://github.com/jhollinger/occams-record/?tab=readme-ov-file#advanced-eager-loading) deeper into ActiveRecord, making them easier to use in existing applications. It's usable in production, but **note that it monkeypatches** `ActiveRecord::Relation#preload_associations`. YMMV if other gems monkeypatch this method.

## Interaction with preload and includes

When `uberload` is used, `preload` and `includes` are de-duped. The following will result in **one** query for `parts`, ordered by name:

```ruby
widgets = Widget
  .preload(:parts)
  .uberload(:parts, scope: Part.order(:name))
```

## Testing

Testing is fully scripted under the `bin/` directory. Appraisal is used to test against various ActiveRecord versions, and Docker or Podman is used to test against various Ruby versions. The combinations to test are defined in [test/matrix](https://github.com/jhollinger/uberloader/blob/main/test/matrix).

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
