module Uberloader
  class Query
    include Preloadable
    include Enumerable

    def initialize(relation)
      @relation = relation
      @preloads = []
      @scopes = []
      @context = Context.new(self)
    end

    def to_a
      records = @relation.to_a
      @preloads.each { |p| p.preload! records }
      records
    end

    #def find_each
    #end

    #def find_in_batches
    #end

    def each
      if block_given?
        to_a.each { |row| yield row }
      else
        to_a.each
      end
    end
  end
end
