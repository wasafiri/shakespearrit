require 'yt'

Yt.configure do |config|
  config.client_id = ENV['YT_CLIENT_ID']
  config.client_secret = ENV['YT_CLIENT_SECRET']
  config.api_key = ENV['YT_API_KEY'] # Optional, but good to have
end
