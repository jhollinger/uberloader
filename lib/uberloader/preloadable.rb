module Uberloader
  # Requires: @scopes, @context, @preloads
  module Preloadable
    def scope(q)
      @scopes << q
      self
    end

    def preload(association, scope: nil, &block)
      @preloads << Preload.new(@context, association, scope: scope, &block)
      self
    end

    def scoped
      @scopes.reduce { |acc, scope| acc.merge scope }
    end
  end
end
