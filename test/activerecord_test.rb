require 'test_helper'

class ActiverecordTest < Minitest::Test
  include TestHelpers

  def setup
    record_queries
  end

  def teardown
    clear_queries
  end

  def test_nested_queries
    widgets = Widget.all
      .uberload(:category, Category.order(:name)) { |u|
        u.uberload(:widgets) {
          u.scope Widget.where.not(id: 256)
          u.uberload(:detail)
        }
      }
      .to_a

    assert widgets[0].category.widgets.loaded?
    assert_equal [
      'SELECT "widgets".* FROM "widgets"',
      'SELECT "categories".* FROM "categories" WHERE "categories"."id" IN (?, ?) ORDER BY "categories"."name" ASC',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."id" != ? AND "widgets"."category_id" IN (?, ?)',
      'SELECT "widget_details".* FROM "widget_details" WHERE "widget_details"."widget_id" IN (?, ?, ?, ?, ?, ?, ?)',
    ], @queries.map(&:first)
  end

  def test_merges_with_preloads
    widgets = Widget.all
      .preload(category: {widgets: :detail})
      .uberload(:category, Category.order(:name))
      .to_a

    assert widgets[0].category.widgets.loaded?
    assert_equal [
      'SELECT "widgets".* FROM "widgets"',
      'SELECT "categories".* FROM "categories" WHERE "categories"."id" IN (?, ?) ORDER BY "categories"."name" ASC',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."category_id" IN (?, ?)',
      'SELECT "widget_details".* FROM "widget_details" WHERE "widget_details"."widget_id" IN (?, ?, ?, ?, ?, ?, ?)',
    ], @queries.map(&:first)
  end

  def test_merges_with_includes
    widgets = Widget.all
      .includes(category: {widgets: :detail})
      .uberload(:category, Category.order(:name))
      .to_a

    assert widgets[0].category.widgets.loaded?
    assert_equal [
      'SELECT "widgets".* FROM "widgets"',
      'SELECT "categories".* FROM "categories" WHERE "categories"."id" IN (?, ?) ORDER BY "categories"."name" ASC',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."category_id" IN (?, ?)',
      'SELECT "widget_details".* FROM "widget_details" WHERE "widget_details"."widget_id" IN (?, ?, ?, ?, ?, ?, ?)',
    ], @queries.map(&:first)
  end
end
