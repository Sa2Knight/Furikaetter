require 'twitter_oauth'
class Twitter

  # initialize - usernameでインスタンスを生成する
  #---------------------------------------------------------------------
  def initialize(username = nil)

    # APIのアクセスキーを取得
    twitter_api = Util.read_twitter_oauth_key
    key = twitter_api['key']
    secret = twitter_api['secret']
    a_token = nil
    a_secret = nil
    # ユーザの指定がある場合OAuthキーを取得
    if username
      if @access_token = Util.read_secret(@username)
        a_token = @access_token[:token] || nil
        a_secret = @access_token[:secret] || nil
      end
    end

    # TwitterAPIの利用開始
    @twitter = TwitterOAuth::Client.new(
        :consumer_key => key,
        :consumer_secret => secret,
        :token => a_token,
        :secret => a_secret
    )
    @authed = @twitter && @twitter.info['screen_name'] ? true : false
  end

  # request_token - Twitter認証用のURLを生成する
  #--------------------------------------------------------------------
  def request_token(callback)
    request_token = @twitter.request_token(:oauth_callback => callback)
    return request_token
  end

  # set_access_token - Twitter連携用のアクセストークンを保存
  #--------------------------------------------------------------------
  def set_access_token(req_token , req_secret , verifier)
    @token = @twitter.authorize(req_token , req_secret , :oauth_verifier => verifier)
    Util.set_user_info(@token.token , {
      :secret => @token.secret,
      :username => @twitter.info['screen_name'],
      :icon => @twitter.info['profile_image_url'],
      :created_at => Time.now.strftime('%Y-%m-%d %H:%M:%S')
    })
    @authed = true
  end

  # usertoken - ユーザのトークンを取得する
  #--------------------------------------------------------------------
  def usertoken
    @authed and return @token.token
  end

  # username - ユーザ名を取得する
  #--------------------------------------------------------------------
  def username
    @authed and return @twitter.info['screen_name']
  end

  # icon - ユーザのアイコンを取得する
  #--------------------------------------------------------------------
  def icon
    @authed and return @twitter.info['profile_image_url']
  end

  # tweets200 - ユーザのツイート一覧を直近200件取得
  #--------------------------------------------------------------------
  def tweets200(page = 0)
    opt = {:trim_user => true , :count => 200 , :page => page}
    origin_tweets = []
    begin
      origin_tweets = @twitter.user_timeline(opt)
    rescue => err
      sleep 3
      retry
    end
    tweets = []
    origin_tweets.each do |t|
      tweets.push ({:datetime => Util.to_datetime(t['created_at']), :text => t['text']})
    end
    p tweets
    tweets
  end

  # tweets3600 - ユーザのツイート一覧を直近3600件取得
  #--------------------------------------------------------------------
  def tweets3600
    @tweets = []
    page = 0
    while @tweets.length < 3600
        tweets_result = self.tweets200(page)
        tweets_result.empty? and break
        @tweets.concat tweets_result
        page += 1
    end
    return @tweets.uniq
  end

  # analysis - ツイート内容から、リプライ先、URL、ハッシュタグを抜き出す
  #----------------------------------------------------------------------
  def analysis(index)
    tweet = @tweets[index]
    tweet_info = Hash.new
    tweet_info[:reply_to] = tweet.scan(/@\w+/).flatten
    tweet_info[:attachment_url] = tweet.scan(%r|(https?://[\w/:%#\$&\?\(\)~\.=\+\-]+)|).flatten
    tweet_info[:hash_tag] = tweet.scan(%r|\s?(#[^ 　]+)\s?|).flatten
    return tweet_info
  end

end
