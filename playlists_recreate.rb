require 'sqlite3'
require 'net/http'
require 'uri'
require 'json'
require 'dotenv'
require './lib/tools.rb'

Dotenv.load

db = SQLite3::Database.new "breaktube-prod.db"


db.execute <<-SQL
  create table playlists_test (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  user_name TEXT NOT NULL,
  youtube_id TEXT NOT NULL,
  title_name TEXT NOT NULL,
  playback_time INTEGER NOT NULL,
  created_at INT NOT NULL
  );
SQL


results = db.execute("SELECT * FROM playlists")


results.each do |arr|
  title_name = check_title(arr[2])
  playback_time = check_video_seconds(arr[2])
  db.execute("INSERT INTO playlists_test (user_name, youtube_id, title_name, playback_time, created_at) VALUES (?, ?, ?, ?, ?)",
             [arr[1], arr[2], title_name, playback_time, arr[3]])
end
