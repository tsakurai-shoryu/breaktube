require 'sqlite3'

class DataBase
  def initialize
    @dbenv = ENV.fetch('DB_PATH', "breaktube-prod.db")
  end

  def youtube_id_search?(youtube_id)
    db = SQLite3::Database.new @dbenv
    db.execute("SELECT youtube_id FROM playlists WHERE youtube_id = \"#{youtube_id}\"").empty?.!
  end

  def playlist_id_search(youtube_id)
    db = SQLite3::Database.new @dbenv
    db.execute("SELECT id FROM playlists WHERE youtube_id = \"#{youtube_id}\"")
  end

  def playlists_insert(user_name,youtube_id)
    c_at = Time.now.to_i
    title_name = check_title(youtube_id)
    playback_time = check_video_seconds(youtube_id)
    db = SQLite3::Database.new @dbenv
    db.execute("INSERT INTO playlists (user_name, youtube_id, title_name, playback_time, created_at) VALUES (?, ?, ?, ?, ?)",
               [user_name, youtube_id, title_name, playback_time, c_at])
  end

  def playlists_count
    db = SQLite3::Database.new @dbenv
    db.execute("SELECT COUNT(1) FROM playlists").flatten[0].to_i
  end

  def get_title(youtube_id)
    db = SQLite3::Database.new @dbenv
    db.execute("SELECT title_name FROM playlists WHERE youtube_id = \"#{youtube_id}\"").flatten[0]
  end

  def get_video_seconds(youtube_id)
    db = SQLite3::Database.new @dbenv
    db.execute("SELECT playback_time FROM playlists WHERE youtube_id = \"#{youtube_id}\"").flatten[0].to_i
  end

  def rand_pick(range: 0)
    db = SQLite3::Database.new @dbenv
    sql = <<EOS
SELECT youtube_id
FROM(
  SELECT id, youtube_id
  FROM playlists
EOS
    sql << "ORDER BY id DESC limit #{range}" if range != 0
    sql << ")"
    db.execute(sql).flatten.sample
  end

  def short_video_pick
    db = SQLite3::Database.new @dbenv
    db.execute("SELECT youtube_id FROM playlists WHERE playback_time <= 600 ").flatten.sample
  end

  def ranking_pick
    db = SQLite3::Database.new @dbenv
    ranking = "breaktube曲追加ランキング\n"
    sql = <<EOS
SELECT user_name, COUNT(1) AS value
FROM playlists
GROUP BY user_name
ORDER BY value DESC
EOS
    results = db.execute(sql)
    results.each.with_index(1) {|ar, index| ar << index}
    results.each_cons(2) do |(l,r)|
      r[2] = l[2] if l[1] == r[1]
    end
    results.each do |arr|
      ranking << "#{arr[2]}位：#{arr[0]}  #{arr[1]}曲\n"
    end
    ranking
  end

  def list(page)
    db = SQLite3::Database.new @dbenv
    limit = 50 # マジックナンバーである
    offset = page * limit
    db.execute("select youtube_id, user_name, title_name from playlists order by id desc limit #{limit} offset #{offset}")
  end

  def all
    db = SQLite3::Database.new @dbenv
    db.execute("select youtube_id, user_name, title_name from playlists order by id desc")
  end
end
