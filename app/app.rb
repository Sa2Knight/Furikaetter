require 'sinatra/base'
require 'rack/flash'

class App < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'

  configure do
    use Rack::Flash
    enable :sessions
  end

  get '/' do
    erb :index
  end

end
