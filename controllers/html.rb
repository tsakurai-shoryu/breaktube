module App
  class Base < ::Sinatra::Base
    get '/' do
      haml :index
    end
  end
end