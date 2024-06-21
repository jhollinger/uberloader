module Uberloader
  # Describes an association to preload (and its children)
  class Uberload
    # @return [Uberloader::Collection]
    attr_reader :children

    #
    # @param context [Uberloader::Context]
    # @param name [Symbol] Name of the association
    # @param scope [ActiveRecord::Relation] optional scope to apply to the association's query
    # @yield [Uberloader::Context] Optional block to customize scope or add child associations
    #
    def initialize(context, name, scope = nil, &block)
      @context = context
      @name = name
      @scopes = scope ? [scope] : []
      @children = Collection.new(context)
      self.block(&block) if block
    end

    #
    # Uberload an association.
    #
    #   Category.all.
    #     uberload(:widget, Widget.order(:name)) { |u|
    #       u.uberload(:parts) {
    #         u.scope Part.active
    #         u.uberload(:foo)
    #       }
    #     }
    #
    # @param association [Symbol] Name of the association
    # @param scope [ActiveRecord::Relation] Optional scope to apply to the association's query
    # @yield [Uberloader::Context] Optional block to customize scope or add child associations
    # @return [Uberloader::Uberload]
    #
    def uberload(association, scope = nil, &block)
      @children.add(association, scope, &block)
      self
    end

    #
    # Append a scope to the association.
    #
    #   Category.all.
    #     uberload(:widget) { |u|
    #       u.scope Widget.active
    #       u.scope Widget.order(:name)
    #     }
    #
    # @param rel [ActiveRecord::Relation]
    # @return [Uberloader::Uberload]
    #
    def scope(rel)
      @scopes << rel
      self
    end

    # Run a block against this level
    def block(&block)
      @context.using(self, &block)
      self
    end

    # Load @children into records
    def uberload!(parent_records, strict_loading = false)
      # Load @name into parent records
      Preloader.call(parent_records, @name, scoped(strict_loading))

      # Load child records into @name
      records = parent_records.each_with_object([]) { |parent, acc|
        acc.concat Array(parent.public_send @name)
      }
      @children.uberload! records, strict_loading if records.any?
    end

    # Returns a nested Hash of the uberloaded associations
    # @return [Hash]
    def to_h
      h = {}
      h[@name] = @children.to_h
      h
    end

    private

    def scoped(strict_loading)
      q = @scopes.reduce { |acc, scope| acc.merge scope }
      if !strict_loading
        q
      elsif q
        q.respond_to?(:strict_loading) ? q.strict_loading : q
      elsif defined? ::ActiveRecord::Relation::StrictLoadingScope
        ::ActiveRecord::Relation::StrictLoadingScope
      end
    end
  end
end
