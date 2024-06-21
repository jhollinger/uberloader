require 'test_helper'

class QueryTest < Minitest::Test
  include TestHelpers

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
