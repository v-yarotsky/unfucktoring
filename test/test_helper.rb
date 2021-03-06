require 'bundler/setup'

require 'minitest/mock'
require 'minitest/autorun'
require 'minitest/pride'

FIXTURES_PATH = File.expand_path('../fixtures', __FILE__)

class UnfucktoringTestCase < Minitest::Test
  def self.test(name, &block)
    define_method("test_#{name.gsub(/\s/, "_")}", &block)
  end
end

$: << File.expand_path('../../lib', __FILE__)
