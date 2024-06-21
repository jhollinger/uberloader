require 'json'
require 'uberloader'
require 'active_record'
require 'minitest/autorun'

Dir.glob('./test/support/*.rb').each { |file| require file }

OTR::ActiveRecord.establish_connection!
Schema.load!
Fixtures.load!
