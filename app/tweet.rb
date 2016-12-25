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

  # 指定したキーを集計
  def aggregate(key , opt = {})
    counts = Hash.new(0)
    @tweets.each do |t|
      target = t[key]
      opt[:deep_key] and target = target[opt[:deep_key]]
      if target.class == Array
        target.each do |p|
          counts[p] += 1
        end
      else
        counts[target] += 1
      end
    end
    counts = counts.sort_by {|k,v| v}.reverse
    if opt[:others] && counts.size > 9
      others = counts[9..-1].inject(0) {|sum , c| sum + c[1]}
      counts[9] = ['その他' , others]
      counts = counts[0..9]
    end
    return counts
  end

  # 指定したキーを持つツイート数を取得
  def count_of(key)
    @tweets.count {|t| t[key].size > 0}
  end

end
