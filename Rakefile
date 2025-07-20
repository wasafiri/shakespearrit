require_relative "db"
require "rake"
require "sequel"
require "rake/testtask"

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

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

task default: :test

namespace :assets do
  desc "Precompile assets"
  task :precompile do
    require "./shakespeare_app"
    ShakespeareApp.compile_assets
  end
end
