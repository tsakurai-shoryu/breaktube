class DataBase
  def youtube_id_search?(youtube_id)
    playlists = DB[:playlists]
    playlists.where(youtube_id: youtube_id).empty?.!
  end

  # obsoleted
  def playlist_id_search(youtube_id)
    # db = SQLite3::Database.new @dbenv
    # db.execute("SELECT id FROM playlists WHERE youtube_id = \"#{youtube_id}\"")
  end

  def playlists_insert(user_name,youtube_id)
    c_at = Time.now.to_i
    title_name = check_title(youtube_id)
    playback_time = check_video_seconds(youtube_id)
    DB[:playlists].insert(user_name: user_name, youtube_id: youtube_id, title_name: title_name, playback_time: playback_time, created_at: c_at)
  end

  def finishlists_insert(youtube_id)
    DB[:finishlists].insert(youtube_id: youtube_id)
  end

  def playlists_count
    DB[:playlists].count
  end

  def get_title(youtube_id)
    DB[:playlists].where(youtube_id: youtube_id).first[:title_name]
  end

  def get_video_seconds(youtube_id)
    DB[:playlists].where(youtube_id: youtube_id).first[:playback_time].to_i
  end

  def rand_pick(range: 0)
    sql = DB[:playlists].reverse_order(:id)
    sql = sql.limit(range) if range != 0
    sql.map(:youtube_id).sample
  end

  def short_video_pick
    finished = DB[:finishlists].map(:youtube_id)
    y_id = DB[:playlists].where{playback_time <= 600}.exclude(youtube_id: finished).map(:youtube_id).sample
    y_id = DB[:playlists].where{playback_time <= 600}.map(:youtube_id).sample if y_id.nil?
    y_id
  end

  def ranking_pick
    ranking = "breaktube曲追加ランキング\n"
    sql = <<EOS
SELECT user_name, COUNT(1) AS value
FROM playlists
GROUP BY user_name
ORDER BY value DESC
EOS
    results = DB[sql].map{ |row| row.values }
    results.each.with_index(1) do |ar, index|
      ar << index
    end
    results.each_cons(2) do |(l,r)|
      r[2] = l[2] if l[1] == r[1]
    end
    results.each do |arr|
      ranking << "#{arr[2]}位：#{arr[0]}  #{arr[1]}曲\n"
    end
    ranking
  end

  # obsoleted
  def list(page)
    # db = SQLite3::Database.new @dbenv
    # limit = 50 # マジックナンバーである
    # offset = page * limit
    # db.execute("select youtube_id, user_name, title_name from playlists order by id desc limit #{limit} offset #{offset}")
  end

  def all
    DB[:playlists].select(:youtube_id, :user_name, :title_name).reverse_order(:id).map{ |s| s.values }
  end
end
