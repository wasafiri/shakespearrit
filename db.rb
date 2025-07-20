require "sequel"
require "logger"


DB = Sequel.connect(ENV.fetch("DATABASE_URL") {
  "postgres://localhost:5432/shakespeare_app_development"
})

# Optional: any DB-specific config, e.g.:
DB.extension :pg_json
DB.extension :pg_enum
DB.loggers << Logger.new($stdout) unless ENV["RACK_ENV"] == "test"
