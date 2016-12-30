require 'sinatra/base'
require 'rack/flash'
require_relative 'util'
require_relative 'twitter'
require_relative 'tweet'

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

  # ツイート集計ページ
  get '/furikaeri/:user' do
    userinfo = Util.get_user_info(params[:user])
    tweet = Tweet.new(params[:user])
    tweet.tweets or redirect '/'
    reply_num = tweet.count_of(:reply_to)
    hash_num = tweet.count_of(:hash_tag)
    @username = userinfo[:username]
    @usericon = userinfo[:icon]
    @created_at = userinfo[:created_at]
    @tweet_num = tweet.tweets.length
    @rep_rate = [['通常ツイート' , @tweet_num - reply_num] , ['リプライツイート' , reply_num]]
    @hash_rate = [['ハッシュタグなし' , @tweet_num - hash_num] , ['ハッシュタグあり' , hash_num]]
    @rep_target_rate = Util.to_json(tweet.aggregate(:reply_to , {:others => true}))
    @hash_used_rate = Util.to_json(tweet.aggregate(:hash_tag , {:others => true}))
    erb :furikaeri
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
      usertoken = twitter.usertoken
      unless tweets = Util.load_tweets(usertoken)
        tweets = twitter.tweets3600
        Util.save_tweets(usertoken , tweets)
      end
      session[:user] = usertoken
      redirect "/furikaeri/#{usertoken}"
    else
      flash['message'] = 'Twitterの認証連携に失敗しました'
      redirect '/'
    end
  end

end
