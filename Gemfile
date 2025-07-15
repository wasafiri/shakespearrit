# frozen_string_literal: true

source "https://rubygems.org"

# Core Application Gems
gem "roda", "~> 3.88"
gem "sequel", "~> 5.80"
gem "pg", "~> 1.5"
gem "bcrypt", "~> 3.1"
gem "pagy", "~> 9.3"
gem "puma", "~> 6.4"
gem 'yt', '~> 0.34.0' # for Youtube API - uploads, comments, downloads, etc

# Gems for development environment
group :development do
  gem "dotenv", "~> 3.1" # Loads .env file in development
  # gem "pry" # Uncomment for a powerful debugging console
end

# Gems for test environment
group :test do
  gem "minitest", "~> 5.24" # Standard testing library
  gem "rack-test", "~> 2.1" # For testing Rack-based apps
end
