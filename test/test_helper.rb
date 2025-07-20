ENV['RACK_ENV'] = 'test'

require "bundler/setup"
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'

# The main app file
require_relative '../shakespeare_app'

# Base class for all our tests
class Minitest::Spec
  include Rack::Test::Methods

  # Wrap each test in a transaction for database isolation
  def before_setup
    super
    DB.transaction(rollback: :always, auto_savepoint: true) { @db_transaction = true }
  end

  def after_teardown
    super
  end

  # Provides the Roda app instance for Rack::Test
  def app
    ShakespeareApp
  end

  # Helper methods to create test data (factories)
  def create_user(params = {})
    defaults = {
      email: "test_user_#{rand(10000)}@example.com",
      password: "password123",
      display_name: "Test User",
      karma: 10, # Default karma from TODO
      has_completed_orientation: true # Assume most tests are for users who are onboarded
    }
    User.create(defaults.merge(params))
  end

  def create_play
    Play.find_or_create(title: "Twelfth Night", author: "William Shakespeare")
  end

  def create_speech_line(play)
    act = Act.find_or_create(play_id: play.id, act_number: 1)
    scene = Scene.find_or_create(act_id: act.id, scene_number: 1)
    speech = Speech.find_or_create(scene_id: scene.id, speaker_name: "ORSINO")
    SpeechLine.create(speech_id: speech.id, text: "If music be the food of love, play on.")
  end

  def create_interpretation(user, speech_line, params = {})
    interp = Interpretation.new(
      user_id: user.id,
      speech_line_id: speech_line.id
    )
    interp.set(params)
    interp.save(validate: false) # Save without validation for test data setup
    interp
  end

  # Helper for parsing JSON responses
  def json_response
    JSON.parse(last_response.body)
  end

  # Helper for logging in a user within a test
  def login_as(user)
    # This simulates a stateful login by directly manipulating the session.
    # In a real API, this would be a request that returns a token.
    post '/api/v1/login', { email: user.email, password: 'password123' }
  end
end
