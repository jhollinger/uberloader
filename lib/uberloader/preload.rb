module Uberloader
  class Preload
    include Preloadable

    def initialize(context, name, scope: nil, &block)
      @name = name
      @context = context
      @scopes = scope ? [scope] : []
      @preloads = []
      @context.using(self, &block) if block
    end

    def preload!(parent_records)
      Preloader.call(parent_records, @name, scoped)
      records = parent_records.each_with_object([]) { |parent, acc|
        acc.concat Array(parent.public_send @name)
      }
      @preloads.each { |p| p.preload! records } if records.any?
    end
  end
end
