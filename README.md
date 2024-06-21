# Uberloaderer

```ruby
widgets = UberLoader.
  query(Widgets.all).
  preload(:category).
  preload(:parts, scope: Part.active) do |u|
    u.scope Part.active

    u.preload(:subparts) do
      u.preload(:foo)
    end
  end.
  to_a
```
