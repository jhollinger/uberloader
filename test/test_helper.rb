require 'json'
require 'uberloader'
require 'uberloader/activerecord'
require 'minitest/autorun'

Dir.glob('./test/support/*.rb').each { |file| require file }

OTR::ActiveRecord.establish_connection!
Schema.load!
Fixtures.load!
