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
    token = @twitter.authorize(req_token , req_secret , :oauth_verifier => verifier)
    Util.set_user_info(token.token , {
      :secret => token.secret,
      :username => @twitter.info['screen_name'],
      :icon => @twitter.info['profile_image_url'],
    })
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

  # tweets - ユーザのツイート一覧を取得
  #--------------------------------------------------------------------
  def tweets
    tweets = @twitter.user_timeline(:trim_user => true , :count => 200)
    tweets.map {|t| t['text']}
  end

end
