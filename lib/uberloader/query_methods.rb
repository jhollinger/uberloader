module Uberloader
  module QueryMethods
    module Delegates
      def uberload(association, scope = nil, &block)
        all.uberload(association, scope, &block)
      end
    end

    def uberload(association, scope = nil, &block)
      spawn.uberload!(association, scope, &block)
    end

    # See uberload
    def uberload!(association, scope = nil, &block)
      @values[:uberloads] ||= Collection.new(Context.new)
      @values[:uberloads].add(association, scope, &block)
      self
    end

    # Overrides preload_associations in ActiveRecord::Relation
    def preload_associations(records)
      if (uberloads = @values[:uberloads])
        preload = preload_values
        preload += includes_values unless eager_loading?
        uberloads.add_preload_values preload

        strict = respond_to?(:strict_loading_value) ? strict_loading_value : nil
        uberloads.uberload! records, strict
      else
        super
      end
    end
  end
end
