module Uberloader
  # Describes an association to preload (and its children)
  class Uberload
    # @return [Uberloader::Collection]
    attr_reader :children

    #
    # @param context [Uberloader::Context]
    # @param name [Symbol] Name of the association
    # @param scope [ActiveRecord::Relation] optional scope to apply to the association's query
    # @param from [Symbol] The real association if "name" is fake
    # @yield [Uberloader::Context] Optional block to customize scope or add child associations
    #
    def initialize(context, name, scope: nil, from: nil, &block)
      @context = context
      @name = name
      @from = from
      @scopes = scope ? [scope] : []
      @children = Collection.new(context)
      self.block(&block) if block
    end

    #
    # Uberload an association.
    #
    #   Category.all.
    #     uberload(:widget, scope: Widget.order(:name)) { |u|
    #       u.uberload(:parts) {
    #         u.scope Part.active
    #         u.uberload(:foo)
    #       }
    #     }
    #
    # @param association [Symbol] Name of the association
    # @param scope [ActiveRecord::Relation] Optional scope to apply to the association's query
    # @param from [Symbol] The real association if "association" is fake
    # @yield [Uberloader::Context] Optional block to customize scope or add child associations
    # @return [Uberloader::Uberload]
    #
    def uberload(association, scope: nil, from: nil, &block)
      @children.add(association, scope: scope, from: from, &block)
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
    def uberload!(raw_parent_records, strict_loading = false)
      return if raw_parent_records.empty?

      parent_records = @from ? subclassed_records(raw_parent_records) : raw_parent_records

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

    def subclassed_records(records)
      model = records[0].class
      ref = model.reflections.fetch(@from.to_s)
      name = @name

      submodel = Class.new(model) do
        def self.name
          superclass.name
        end

        send ref.macro, name, ref.scope, **{
          class_name: ref.klass.name,
          primary_key: ref.klass.primary_key,
          foreign_key: ref.foreign_key,
        }.merge(ref.options)
      end

      records.map { |record|
        x = submodel.new(record.attributes)
        record.instance_eval do
          (class << self; self; end).class_eval do
            define_method(name) { x.send name }
          end
        end
        x
      }
    end
  end
end
