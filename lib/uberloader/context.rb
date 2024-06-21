require 'forwardable'

module Uberloader
  class Context
    extend Forwardable

    def initialize(preloadable)
      @preloadable = preloadable
    end

    def using(preloadable)
      prev = @preloadable
      @preloadable = preloadable
      yield self
      @preloadable = prev
    end

    def_delegators :@preloadable, :scope, :preload
  end
end
