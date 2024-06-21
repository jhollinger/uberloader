require 'active_record'

module Uberloader
  autoload :Context, 'uberloader/context'
  autoload :Uberload, 'uberloader/uberload'
  autoload :Uberloadable, 'uberloader/uberloadable'
  autoload :Query, 'uberloader/query'
  autoload :Version, 'uberloader/version'

  autoload :Preloader,
    case ActiveRecord::VERSION::MAJOR
    when 7 then 'uberloader/preloader/v7'
    when 6 then 'uberloader/preloader/v6'
    else raise "Unsupported ActiveRecord version"
    end

  def self.query(relation)
    Query.new(relation)
  end
end
