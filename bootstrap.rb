ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir.glob("#{File.dirname(__FILE__)}/libs/*.rb").each { |rb| require rb }
Dir.glob("#{File.dirname(__FILE__)}/controllers/*.rb").each { |rb| require rb }

module App
  class Base < ::Sinatra::Base
    configure do
      enable :logging
      enable :raise_errors, :logging
      enable :show_exceptions

      set server: "thin", connections: [], history_file: "history.yml"
      set :bind, '0.0.0.0'
      set :app_file, __FILE__
    end
  end
end

Dotenv.load

Slack.configure do |config|
  config.token = ENV["S_TOKEN"]
end
