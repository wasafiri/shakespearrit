# Load initializers
Dir['./config/initializers/**/*.rb'].each { |file| require file }

require_relative "shakespeare_app"
run ShakespeareApp.freeze.app