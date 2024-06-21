module Uberloader
  class Uberload
    include Uberloadable

    attr_reader :name

    def initialize(context, name, scope: nil, &block)
      @name = name
      @context = context
      @scopes = scope ? [scope] : []
      @uberloads = []
      @context.using(self, &block) if block
    end

    def preload!(parent_records)
      Preloader.call(parent_records, @name, scoped)
      records = parent_records.each_with_object([]) { |parent, acc|
        acc.concat Array(parent.public_send @name)
      }
      @uberloads.each { |p| p.preload! records } if records.any?
    end

    def to_h
      h = {}
      h[@name] = @uberloads.reduce({}) { |acc, p|
        acc.merge p.to_h
      }
      h
    end
  end
end
