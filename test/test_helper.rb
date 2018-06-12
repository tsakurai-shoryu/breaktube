ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require :default, :test

require 'minitest/autorun'
require 'rack/test'

require_relative '../bootstrap'

class TestHelper < MiniTest::Test
  include Rack::Test::Methods

  def app
    App::Base
  end
end