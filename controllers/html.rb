module App
  class Base < ::Sinatra::Base
    get '/' do
      erb :index
    end
  end
end