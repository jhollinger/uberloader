require 'test_helper'

class QueryTest < Minitest::Test
  include TestHelpers

  def setup
    @queries = []
    @sub = ActiveSupport::Notifications.subscribe 'sql.active_record' do |_name, _started, _finished, _uid, data|
      @queries << [data.fetch(:sql), data.fetch(:type_casted_binds)]
    end
  end

  def teardown
    ActiveSupport::Notifications.unsubscribe @sub
    @queries.clear
  end

  def test_preloading
    categories = Uberloader
      .query(Category.order(:name))
      .uberload(:widgets) { |u|
        u.scope Widget.where.not(name: nil)
        u.uberload(:line_items)
      }
      .to_a

    categories[0].widgets
    assert_equal [
      'SELECT "categories".* FROM "categories" ORDER BY "categories"."name" ASC',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."name" IS NOT NULL AND "widgets"."category_id" IN (?, ?)',
      'SELECT "line_items".* FROM "line_items" WHERE "line_items"."item_type" = ? AND "line_items"."item_id" IN (?, ?, ?, ?, ?, ?, ?)',
    ], @queries.map(&:first)

    assert_equal Category.order(:name).pluck(:name), categories.map(&:name)
    assert_equal Category.find(categories[0].id).widgets.pluck(:name), categories[0].widgets.map(&:name)
  end

  def test_find_in_batches
    categories = []
    Uberloader
      .query(Category.order(:name))
      .uberload(:widgets) { |u|
        u.scope Widget.where.not(name: nil)
        u.uberload(:line_items)
      }
      .find_in_batches { |records| categories.concat records }

    assert_equal [
      'SELECT "categories".* FROM "categories" ORDER BY "categories"."id" ASC LIMIT ?',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."name" IS NOT NULL AND "widgets"."category_id" IN (?, ?)',
      'SELECT "line_items".* FROM "line_items" WHERE "line_items"."item_type" = ? AND "line_items"."item_id" IN (?, ?, ?, ?, ?, ?, ?)',
    ], @queries.map(&:first)

    assert_equal Category.order(:id).pluck(:name), categories.map(&:name)
  end

  def test_find_each
    categories = []
    Uberloader
      .query(Category.order(:name))
      .uberload(:widgets) { |u|
        u.scope Widget.where.not(name: nil)
        u.uberload(:line_items)
      }
      .find_each { |record| categories << record }

    assert_equal [
      'SELECT "categories".* FROM "categories" ORDER BY "categories"."id" ASC LIMIT ?',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."name" IS NOT NULL AND "widgets"."category_id" IN (?, ?)',
      'SELECT "line_items".* FROM "line_items" WHERE "line_items"."item_type" = ? AND "line_items"."item_id" IN (?, ?, ?, ?, ?, ?, ?)',
    ], @queries.map(&:first)

    assert_equal Category.order(:id).pluck(:name), categories.map(&:name)
  end

  def test_to_h
    uberload = Uberloader::Uberload.new(Uberloader::Context.new, :widgets) { |u|
      u.scope Widget.where.not(name: nil)
      u.uberload(:line_items)
      u.uberload(:category) {
        u.uberload(:children)
      }
    }
    assert_equal({:widgets=>{:line_items=>{}, :category=>{:children=>{}}}}, uberload.to_h)
  end
end
