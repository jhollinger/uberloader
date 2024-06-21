module Uberloader
  class Query
    include Enumerable

    def initialize(relation)
      @relation = relation
      @scopes = []
      @context = Context.new(self)
      @children = Collection.new(Context.new)
    end

    def uberload(association, scope: nil, &block)
      @children.add(association, scope: scope, &block)
      self
    end

    def to_a
      records = @relation.to_a
      @children.preload! records if records.any?
      records
    end

    def each
      if block_given?
        to_a.each { |row| yield row }
      else
        to_a.each
      end
    end

    def find_each(start: nil, finish: nil, batch_size: 1000, error_on_ignore: nil)
      enum = Enumerator.new { |y|
        find_in_batches(start: start, finish: finish, batch_size: batch_size, error_on_ignore: error_on_ignore) do |records|
          records.each { |record| y << record }
        end
      }
      if block_given?
        enum.each { |row| yield row }
      else
        enum.each
      end
    end

    def find_in_batches(start: nil, finish: nil, batch_size: 1000, error_on_ignore: nil)
      enum = Enumerator.new { |y|
        @relation.find_in_batches(start: start, finish: finish, batch_size: batch_size, error_on_ignore: error_on_ignore) do |records|
          @children.preload! records if records.any?
          y << records
        end
      }
      if block_given?
        enum.each { |records| yield records }
      else
        enum.each
      end
    end
  end
end
