require_relative 'util'
class Tweet

  attr_reader :tweets

  # ユーザ名を指定してインスタンス生成
  def initialize(user)
    origin_tweets = Util.load_tweets(user)
    @tweets = []
    origin_tweets.each do |origin|
      tweet = get_info(origin[:text])
      tweet.merge!(origin)
      @tweets.push tweet
    end
  end

  # 1件のツイートを解析する
  def get_info(tweet)
    tweet_info = Hash.new
    tweet_info[:reply_to] = tweet.scan(/@\w+/).flatten
    tweet_info[:attachment_url] = tweet.scan(%r|(https?://[\w/:%#\$&\?\(\)~\.=\+\-]+)|).flatten
    tweet_info[:hash_tag] = tweet.scan(%r|\s?(#[^\s　]+)\s?|).flatten
    return tweet_info
  end

  # リプライ数を集計
  def replays
    self.aggregate(:reply_to)
  end

  # ハッシュタグ数を集計
  def hash_tags
    self.aggregate(:hash_tag)
  end

  # URLを集計
  def attachment_urls
    self.aggregate(:attachment_url)
  end

  # 曜日ごとの集計
  def cwdays
    self.aggregate(:datetime , :cwday)
  end

  # リプライを含むツイート数
  def replay_count
    self.count_of(:reply_to)
  end

  # ハッシュタグを含むツイート数
  def hash_tags_count
    self.count_of(:hash_tag)
  end

  # 指定したキーを集計
  def aggregate(key , deep_key = nil)
    counts = Hash.new(0)
    @tweets.each do |t|
      target = t[key]
      deep_key.nil? or target = target[deep_key]
      if target.class == Array
        target.each do |p|
          counts[p] += 1
        end
      else
        counts[target] += 1
      end
    end
    counts.sort_by {|k,v| v}.reverse
  end

  # 指定したキーを持つツイート数を取得
  def count_of(key)
    @tweets.count {|t| t[key].size > 0}
  end

end
