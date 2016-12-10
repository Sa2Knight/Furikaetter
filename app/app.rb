require 'sinatra/base'
require 'rack/flash'
require_relative 'util'

class App < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'

  configure do
    use Rack::Flash
    enable :sessions
  end

  helpers do
    def base_url
      default_port = (request.scheme == "http") ? 80 : 443
      port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
      "#{request.scheme}://#{request.host}#{port}"
    end
  end

  get '/' do
    erb :index
  end

end
