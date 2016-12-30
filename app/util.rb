require 'date'
require 'yaml'
require 'json'

class Util

  SECRET = 'secret.yml'
  TWEETS = 'tweets'

  def self.read_secret
    YAML.load_file(SECRET)
  end

  def self.read_twitter_oauth_key
    Util.read_secret['twitter_api']
  end

  def self.save_tweets(user , tweets)
    open("#{TWEETS}/#{user}" , "w"){|f| f.write(YAML.dump(tweets))}
  end

  def self.load_tweets(user)
    path = "#{TWEETS}/#{user}"
    File.exists?(path) and YAML.load_file(path)
  end

  def self.set_user_info(key , params)
    secret = Util.read_secret
    secret[key] or secret[key] = {}
    secret[key].merge! params
    if secret['twitter_api'] && secret[key]
      open(SECRET , "w"){|f| f.write(YAML.dump(secret))}
    end
  end

  def self.get_user_info(key)
    Util.read_secret[key]
  end

  def self.to_datetime(str)
    format = "%a %b %d %H:%M:%S %z %Y"
    cw = %w(月曜 火曜 水曜 木曜 金曜 土曜 日曜)
    datetime = DateTime.strptime(str, format)
    return {
      year: datetime.year,
      month: datetime.mon,
      day: datetime.day,
      hour: datetime.hour,
      min: datetime.min,
      cwday: cw[datetime.cwday - 1],
    }
  end

  def self.to_json(object)
    JSON.generate(object)
  end

end
