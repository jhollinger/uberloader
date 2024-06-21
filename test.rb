require 'forwardable'

class Node
  attr_reader :val

  def initialize(val)
    @val = val
  end

  def get
    @val
  end
end

class Context
  extend Forwardable

  attr_accessor :node

  def initialize(node)
    @node = node
  end

  def using(node)
    prev = @node
    @node = node
    yield self
    @node = prev
  end

  def_delegator :@node, :get
end

context = Context.new(Node.new("A"))
puts context.get
context.using Node.new("B") do
  puts context.get
end
puts context.get
