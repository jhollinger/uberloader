require 'forwardable'

module Uberloader
  class Context
    extend Forwardable

    def initialize(uberloadable = nil)
      @uberloadable = uberloadable
    end

    def using(uberloadable)
      prev = @uberloadable
      @uberloadable = uberloadable
      yield self
      @uberloadable = prev
    end

    def_delegators :@uberloadable, :scope, :uberload
  end
end
