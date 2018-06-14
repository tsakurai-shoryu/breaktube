module App
  class Base < ::Sinatra::Base
    get '/' do
      erb :index
    end

    get '/ignore' do
      yid = params[:yid]
      db = DataBase.new
      db.ignore(yid)

      @list = db.all
      erb :list
    end

    get '/grid' do
      @list = DataBase.new.all
      erb :grid
    end

    get '/list' do
      @list = DataBase.new.all
      erb :list
    end
  end
end