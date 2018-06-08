require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "test/**/test_*.rb"
end

namespace :db do
  desc "migrate db"
  task migrate: :environment do
    DB = Sequel.sqlite(ENV.fetch("DB_PATH","breaktube-prod.db"))
    Sequel.extension :migration
    Sequel::Migrator.run(DB, './db/migrations/', use_transactions: true)
  end
end

task :environment do
  require './bootstrap.rb'
end