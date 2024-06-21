module Uberloader
  class Collection
    def initialize(context)
      @context = context
      @uberloads = {}
    end

    def add(association, scope: nil, &block)
      @uberloads[association] ||= Uberload.new(@context, association)
      @uberloads[association].scope scope if scope
      @uberloads[association].block(&block) if block
    end

    def preload!(records, strict_loading = false)
      @uberloads.each_value { |u| u.preload!(records, strict_loading) }
    end

    def to_h
      @uberloads.each_value.reduce({}) { |acc, u|
        acc.merge u.to_h
      }
    end
  end
end
