require 'test_helper'

class CollectionTest < Minitest::Test
  include TestHelpers

  def setup
    @collection = Uberloader::Collection.new(Uberloader::Context.new)
    record_queries
  end

  def teardown
    clear_queries
  end

  def test_add
    @collection.add(:widgets, Widget.where.not(name: "Foo"))
    @collection.add(:widgets) do |u|
      u.scope Widget.order(:name)
      u.scope Widget.where.not(category_id: 200)
      u.uberload(:line_items)
    end

    @collection.uberload! Category.all.to_a, true
    assert_equal [
      'SELECT "categories".* FROM "categories"',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."name" != ? AND "widgets"."category_id" != ? AND "widgets"."category_id" IN (?, ?) ORDER BY "widgets"."name" ASC',
      'SELECT "line_items".* FROM "line_items" WHERE "line_items"."item_type" = ? AND "line_items"."item_id" IN (?, ?, ?, ?, ?, ?, ?)',
    ], @queries.map(&:first)
  end

  def test_add_preload_values
    @collection.add_preload_values(:widgets)
    @collection.add_preload_values({widgets: [:line_items, {category: :children}]})
    assert_equal({:widgets=>{:line_items=>{}, :category=>{:children=>{}}}}, @collection.to_h)
  end

  def test_to_h
    @collection.add(:widgets) { |u|
      u.uberload(:line_items)
      u.uberload(:category) {
        u.uberload(:children)
      }
    }
    assert_equal({:widgets=>{:line_items=>{}, :category=>{:children=>{}}}}, @collection.to_h)
  end
end
