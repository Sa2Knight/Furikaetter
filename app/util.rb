require 'yaml'

class Util

  SECRET = 'secret.yml'

  def self.read_secret
    YAML.load_file(SECRET)
  end

  def self.read_twitter_aouth_key
    Util.read_secret['twitter_api']
  end

end
