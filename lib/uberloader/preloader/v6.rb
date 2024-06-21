module Uberloader
  module Preloader
    def self.call(records, association, scope = nil)
      ::ActiveRecord::Associations::Preloader.new
        .preload(records, association, scope)
    end
  end
end
