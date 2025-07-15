require_relative "db"
require "rake"
require "sequel"

namespace :db do
  desc "Migrate the database (use VERSION=n to rollback)"
  task :migrate do
    Sequel.extension :migration
    Sequel::Migrator.run(DB, "migrate", :use_transactions=>true)
    puts "Database migrated!"
  end

  desc "Roll back the latest migration"
  task :rollback do
    Sequel.extension :migration
    Sequel::Migrator.run(DB, "migrate", :target => (DB[:schema_info].get(:version) - 1))
    puts "Rolled back one step!"
  end
end

desc "Run all tests (placeholder task)"
task :default => ["test"]

desc "Test Task (placeholder)"
task :test do
  puts "No tests yet."
end
