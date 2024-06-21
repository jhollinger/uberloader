module Uberloader
  # Requires: @scopes, @context, @uberloads
  module Uberloadable
    def scope(q)
      @scopes << q
      self
    end

    def uberload(association, scope: nil, &block)
      @uberloads << Uberload.new(@context, association, scope: scope, &block)
      self
    end

    def scoped
      @scopes.reduce { |acc, scope| acc.merge scope }
    end
  end
end
