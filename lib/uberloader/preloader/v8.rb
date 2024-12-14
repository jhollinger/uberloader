module Uberloader
  module Preloader
    def self.call(records, association, scope = nil)
      ::ActiveRecord::Associations::Preloader
        .new(records: records, associations: association, scope: scope)
        .call
    end
  end
end
