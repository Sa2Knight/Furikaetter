require_relative 'util'
class Tweet

  attr_reader :tweets

  # ユーザ名を指定してインスタンス生成
  def initialize(user)
    origin_tweets = Util.load_tweets(user)
    @tweets = []
    origin_tweets.each do |origin|
      tweet = get_info(origin)
      tweet[:origin] = origin
      @tweets.push tweet
    end
  end

  # 1件のツイートを解析する
  def get_info(tweet)
    tweet_info = Hash.new
    tweet_info[:reply_to] = tweet.scan(/@\w+/).flatten
    tweet_info[:attachment_url] = tweet.scan(%r|(https?://[\w/:%#\$&\?\(\)~\.=\+\-]+)|).flatten
    tweet_info[:hash_tag] = tweet.scan(%r|\s?(#[^ 　]+)\s?|).flatten
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

  # 指定したキーを集計
  def aggregate(key)
    counts = Hash.new(0)
    @tweets.each do |t|
      t[key].each do |p|
        counts[p] += 1
      end
    end
    counts.sort_by {|k,v| v}.reverse
  end

end
