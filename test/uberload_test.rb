require 'test_helper'

class QueryTest < Minitest::Test
  include TestHelpers

  def setup
    record_queries
    @context = Uberloader::Context.new
  end

  def teardown
    clear_queries
  end

  def test_initialize
    uberload = Uberloader::Uberload.new(@context, :widgets, Widget.order(:name))
    uberload.uberload! Category.all.to_a

    assert_equal [
      'SELECT "categories".* FROM "categories"',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."category_id" IN (?, ?) ORDER BY "widgets"."name" ASC',
    ], @queries.map(&:first)
  end

  def test_initialize_with_block
    uberload = Uberloader::Uberload.new(@context, :widgets) { |u|
      u.scope Widget.order(:name)
    }
    uberload.uberload! Category.all.to_a

    assert_equal [
      'SELECT "categories".* FROM "categories"',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."category_id" IN (?, ?) ORDER BY "widgets"."name" ASC',
    ], @queries.map(&:first)
  end

  def test_uberload
    uberload = Uberloader::Uberload.new(@context, :widgets)
    uberload.uberload(:detail)
    uberload.uberload(:line_items, LineItem.order(amount: :desc))
    uberload.uberload! Category.all.to_a

    assert_equal [
      'SELECT "categories".* FROM "categories"',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."category_id" IN (?, ?)',
      'SELECT "widget_details".* FROM "widget_details" WHERE "widget_details"."widget_id" IN (?, ?, ?, ?, ?, ?, ?)',
      'SELECT "line_items".* FROM "line_items" WHERE "line_items"."item_type" = ? AND "line_items"."item_id" IN (?, ?, ?, ?, ?, ?, ?) ORDER BY "line_items"."amount" DESC',
    ], @queries.map(&:first)
  end

  def test_scope
    uberload = Uberloader::Uberload.new(@context, :widgets)
    uberload.scope Widget.where(name: "Foo")
    uberload.scope Widget.order(:name)
    uberload.scope Widget.limit(10)
    uberload.uberload! Category.all.to_a

    assert_equal [
      'SELECT "categories".* FROM "categories"',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."name" = ? AND "widgets"."category_id" IN (?, ?) ORDER BY "widgets"."name" ASC LIMIT ?',
    ], @queries.map(&:first)
  end

  def test_block
    uberload = Uberloader::Uberload.new(@context, :widgets)
    uberload.block do |u|
      u.scope Widget.order(:name)
      u.uberload(:line_items)
    end
    uberload.uberload! Category.all.to_a

    assert_equal [
      'SELECT "categories".* FROM "categories"',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."category_id" IN (?, ?) ORDER BY "widgets"."name" ASC',
      'SELECT "line_items".* FROM "line_items" WHERE "line_items"."item_type" = ? AND "line_items"."item_id" IN (?, ?, ?, ?, ?, ?, ?)',
    ], @queries.map(&:first)
  end

  def test_to_h
    uberload = Uberloader::Uberload.new(@context, :widgets) { |u|
      u.scope Widget.where.not(name: nil)
      u.uberload(:line_items)
      u.uberload(:category) {
        u.uberload(:children)
      }
    }
    assert_equal({:widgets=>{:line_items=>{}, :category=>{:children=>{}}}}, uberload.to_h)
  end
end
