require 'test_helper'

class CollectionTest < Minitest::Test
  include TestHelpers

  def test_to_h
    collection = Uberloader::Collection.new(Uberloader::Context.new)
    collection.add(:widgets) { |u|
      u.scope Widget.where.not(name: nil)
      u.uberload(:line_items)
      u.uberload(:category) {
        u.uberload(:children)
      }
    }
    assert_equal({:widgets=>{:line_items=>{}, :category=>{:children=>{}}}}, collection.to_h)
  end
end
