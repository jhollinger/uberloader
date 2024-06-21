module Uberloader
  class Uberload
    def initialize(context, name, scope: nil, &block)
      @context = context
      @name = name
      @scopes = scope ? [scope] : []
      @children = Collection.new(context, &block)
      self.block(&block) if block
    end

    def uberload(association, scope: nil, &block)
      @children.add(association, scope: scope, &block)
      self
    end

    def scope(q)
      @scopes << q
      self
    end

    def block(&block)
      @context.using(self, &block)
    end

    def preload!(parent_records, strict_loading = false)
      # Load @name into parent records
      scoped = @scopes.reduce { |acc, scope| acc.merge scope }
      scope = strict_loading ? scoped&.strict_loading || ::ActiveRecord::Relation::StrictLoadingScope : scoped
      Preloader.call(parent_records, @name, scope)

      # Load child records into @name
      records = parent_records.each_with_object([]) { |parent, acc|
        acc.concat Array(parent.public_send @name)
      }
      @children.preload! records, strict_loading if records.any?
    end

    def to_h
      h = {}
      h[@name] = @children.to_h
      h
    end
  end
end
