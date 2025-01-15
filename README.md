# Uberloader

Uberloader is a new way of preloading associations in ActiveRecord. It behaves like `preload`, but with a lot more power.

#### Install with Bundler

```bash
bundle add uberloader
```

#### Nested preloads use blocks

```ruby
widgets = Widget
  .where(category_id: category_ids)
  .uberload(:category)
  .uberload(:parts) { |u|
    u.uberload(:manufacturer)
    u.uberload(:subparts) {
      u.uberload(:foo) {
        u.uberload(:bar)
      }
    }
  }
```

#### Why? So you can customize preload scopes

```ruby
widgets = Widget
  .where(category_id: category_ids)
  .uberload(:category)
  # specify scope using an argument
  .uberload(:parts, scope: Part.order(:name)) { |u|
    u.uberload(:manufacturer)
    u.uberload(:subparts) {
      # or using the #scope method
      u.scope my_subparts_scope_helper
      u.scope Subpart.where(kind: params[:sub_kinds]) if params[:sub_kinds]&.any?

      u.uberload(:foo) {
        u.uberload(:bar)
      }
    }
  }
```

## Interaction with preload and includes

When `uberload` is used, `preload` and `includes` are de-duped. The following will result in **one** query for `parts`, ordered by name:

```ruby
widgets = Widget
  .preload(:parts)
  .uberload(:parts, scope: Part.order(:name))
```

## On Monkeypatches and Safety

Regretably, none of this is possible without monkeypatching `ActiveRecord::Relation`'s non-public `preload_associations` method. While small, the patch has no guarntee of working in the next minor, or even tiny, patch.

To assess its stability over time, I ran Uberloader's unit tests against the full matrix of (supported) ActiveRecord and Uberloader versions. They passed consistently, but with predictable clusters of failures around pre-release and X.0.0 versions.

I will keep these tests running regularly. [You can find the link to the results here](https://github.com/jhollinger/uberloader/blob/docs/VERSION_COMPATIBILITY.md). If something breaks, I'll try to fix it. If we're lucky, maybe this behavior could get _into_ Rails itself someday...

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

### Version compatibility testing

```bash
# Test all combinations of (supported) ActiveRecord versions against all uberloader versions
bin/testall-compatibility

# Output the results as a Markdown table
bin/generate-version-test-table

# Run tests for specific versions
#                      Appraisal  ActiveRecord  Uberloader
bin/test-compatibility 7.1        7.1.3.2       0.1.0
bin/test-compatibility 7.1        7.1.3.2       HEAD
```
