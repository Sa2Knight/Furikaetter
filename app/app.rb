require 'sinatra/base'
require 'rack/flash'
require_relative 'util'
require_relative 'twitter'

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

  # トップページ
  get '/' do
    @message = flash[:message]
    erb :index
  end

  # OAuth認証
  get '/oauth' do
    twitter = Twitter.new
    request_token = twitter.request_token("#{base_url}/oauthed")
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    redirect request_token.authorize_url
  end

  # OAuth認証完了
  get '/oauthed' do
    if params[:oauth_token] && verifier = params[:oauth_verifier]
      twitter = Twitter.new
      req_token = session[:request_token] || ''
      req_secret = session[:request_token_secret] || ''
      twitter.set_access_token(req_token , req_secret , verifier)
      flash[:message] = 'Twitter連携を設定しました'
    else
      flash['message'] = 'Twitterの認証連携に失敗しました'
    end
    redirect '/'
  end

end
