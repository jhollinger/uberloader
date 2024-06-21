require 'forwardable'

module Uberloader
  # A wrapper around the current uberload, allowing a single block arg to be used no matter how deep we nest uberloads.
  class Context
    extend Forwardable

    #
    # Set a new context and evaluate the block.
    #
    # @param uberload [Uberloader::Uberload]
    def using(uberload)
      prev = @uberload
      @uberload = uberload
      yield self
      @uberload = prev
    end

    def_delegators :@uberload, :scope, :uberload
  end
end
