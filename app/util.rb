require 'yaml'

class Util

  SECRET = 'secret.yml'

  def self.read_secret
    YAML.load_file(SECRET)
  end

  def self.read_twitter_oauth_key
    Util.read_secret['twitter_api']
  end

  def self.set_user_info(key , params)
    secret = Util.read_secret
    secret[key] or secret[key] = {}
    secret[key].merge! params
    if secret['twitter_api'] && secret[key]
      open(SECRET , "w"){|f| f.write(YAML.dump(secret))}
    end
  end

end
