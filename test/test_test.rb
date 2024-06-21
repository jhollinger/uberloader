require 'test_helper'

class TestTest < Minitest::Test
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

  def test_foo
    Uberloader
      .query(Category.all)
      .preload(:widgets) { |u|
        u.scope Widget.where.not(name: nil)
        u.preload(:line_items)
      }
      .to_a

    assert_equal [
      'SELECT "categories".* FROM "categories"',
      'SELECT "widgets".* FROM "widgets" WHERE "widgets"."name" IS NOT NULL AND "widgets"."category_id" IN (?, ?)',
      'SELECT "line_items".* FROM "line_items" WHERE "line_items"."item_type" = ? AND "line_items"."item_id" IN (?, ?, ?, ?, ?, ?, ?)',
    ], @queries.map(&:first)
  end
end
