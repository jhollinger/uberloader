module Uberloader
  # Holds a set of Uberload sibling instances
  class Collection
    # @param context [Uberloader::Context]
    def initialize(context)
      @context = context
      @uberloads = {}
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
    # @yield [Uberloader::Context] Optional Block to customize scope or add child associations
    # @return [Uberloader::Uberload]
    #
    def add(association, scope = nil, &block)
      u = @uberloads[association] ||= Uberload.new(@context, association)
      u.scope scope if scope
      u.block(&block) if block
      u
    end

    #
    # Add preload values from Rails.
    #
    # @param val [Symbol|Array|Hash]
    #
    def add_preload_values(val)
      case val
      when Hash
        val.each { |k,v| add(k).children.add_preload_values(v) }
      when Array
        val.each { |v| add_preload_values v }
      when String
        add val.to_sym
      when Symbol
        add val
      else
        raise ArgumentError, "Unexpected preload value: #{val.inspect}"
      end
    end

    # Load @uberloads into records
    def uberload!(records, strict_loading = false)
      @uberloads.each_value { |u| u.uberload!(records, strict_loading) }
    end

    # Returns a nested Hash of the uberloaded associations
    # @return [Hash]
    def to_h
      @uberloads.each_value.reduce({}) { |acc, u|
        acc.merge u.to_h
      }
    end
  end
end
