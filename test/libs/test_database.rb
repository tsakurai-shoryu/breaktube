require File.expand_path '../test_helper.rb', __dir__

# https://github.com/jeremyevans/sequel
class DatabaseTest < TestHelper
  def test_youtube_id_search?
    reset_db

    DB[:playlists].insert(user_name: "user", youtube_id: "PumFnlu9EIY", title_name: "Title", playback_time: 100, created_at: Time.now.to_i)

    assert db.youtube_id_search?("PumFnlu9EIY")
    refute db.youtube_id_search?("Other_Id")
  end

  def test_playlist_id_search
    reset_db
    # 未使用ぽい
  end

  def test_playlists_insert
    reset_db

    DB[:playlists].insert(user_name: "user", youtube_id: "PumFnlu9EIY", title_name: "Title", playback_time: 100, created_at: Time.now.to_i)
    assert_equal db.playlists_count, 1

    # add same one
    DB[:playlists].insert(user_name: "user", youtube_id: "PumFnlu9EIY", title_name: "Title", playback_time: 100, created_at: Time.now.to_i)
    assert_equal db.playlists_count, 2
  end

  def test_finishlists_insert
    reset_db

    assert_equal DB[:finishlists].count, 0
    db.finishlists_insert("PumFnlu9EIY")
    assert_equal DB[:finishlists].count, 1
  end

  def test_playlists_count
    reset_db

    assert_equal db.playlists_count, 0
  end

  def test_get_title
    reset_db

    DB[:playlists].insert(user_name: "user", youtube_id: "PumFnlu9EIY", title_name: "Title", playback_time: 100, created_at: Time.now.to_i)
    assert_equal db.get_title("PumFnlu9EIY"), "Title"
  end

  def test_get_video_seconds
    reset_db

    DB[:playlists].insert(user_name: "user", youtube_id: "PumFnlu9EIY", title_name: "Title", playback_time: 100, created_at: Time.now.to_i)
    assert_equal db.get_video_seconds("PumFnlu9EIY"), 100
  end

  def test_rand_pick
    reset_db

    DB[:playlists].insert(user_name: "user1", youtube_id: "PumFnlu9EIY", title_name: "600秒以下", playback_time: 100, created_at: Time.now.to_i)
    assert_equal db.rand_pick(range: 1), "PumFnlu9EIY"

    DB[:playlists].insert(user_name: "user1", youtube_id: "o1jAMSQyVPc", title_name: "600秒越え", playback_time: 601, created_at: Time.now.to_i)
    assert_equal db.rand_pick(range: 1), "o1jAMSQyVPc"

    DB[:playlists].insert(user_name: "user1", youtube_id: "BsB-7wZv_kI", title_name: "再生済", playback_time: 100, created_at: Time.now.to_i)
    assert_equal db.rand_pick(range: 1), "BsB-7wZv_kI"
  end

  def test_short_video_pick
    reset_db
    DB[:playlists].insert(user_name: "user1", youtube_id: "PumFnlu9EIY", title_name: "600秒以下", playback_time: 100, created_at: Time.now.to_i)
    DB[:playlists].insert(user_name: "user1", youtube_id: "o1jAMSQyVPc", title_name: "600秒越え", playback_time: 601, created_at: Time.now.to_i)
    DB[:playlists].insert(user_name: "user1", youtube_id: "BsB-7wZv_kI", title_name: "再生済", playback_time: 100, created_at: Time.now.to_i)
    DB[:finishlists].insert(youtube_id: "BsB-7wZv_kI")

    assert_equal db.short_video_pick, "PumFnlu9EIY"
  end

  def test_ranking_pick
    reset_db
    DB[:playlists].insert(user_name: "user1", youtube_id: "PumFnlu9EIY", title_name: "新・豪血寺一族 －煩悩開放－　レッツゴー！陰陽師　PV", playback_time: 100, created_at: Time.now.to_i)
    DB[:playlists].insert(user_name: "user2", youtube_id: "o1jAMSQyVPc", title_name: "初音ミク「メルト」", playback_time: 100, created_at: Time.now.to_i)
    DB[:playlists].insert(user_name: "user1", youtube_id: "BsB-7wZv_kI", title_name: "銀河鉄道スリーナイン The Galaxy Express999　ゴダイゴ", playback_time: 100, created_at: Time.now.to_i)
    DB[:playlists].insert(user_name: "user1", youtube_id: "IntjjhcASVA", title_name: "みずほダンス【＜みずほ＞公式】", playback_time: 100, created_at: Time.now.to_i)

    assert_equal db.ranking_pick, "breaktube曲追加ランキング\n1位：user1  3曲\n2位：user2  1曲\n"
  end

  def test_list
    reset_db
    # 未使用ぽい
  end

  def test_all
    reset_db

    DB[:playlists].insert(user_name: "user1", youtube_id: "PumFnlu9EIY", title_name: "新・豪血寺一族 －煩悩開放－　レッツゴー！陰陽師　PV", playback_time: 100, created_at: Time.now.to_i)
    DB[:playlists].insert(user_name: "user2", youtube_id: "o1jAMSQyVPc", title_name: "初音ミク「メルト」", playback_time: 100, created_at: Time.now.to_i)
    assert_equal db.all, [["o1jAMSQyVPc", "user2", "初音ミク「メルト」", 100], ["PumFnlu9EIY", "user1", "新・豪血寺一族 －煩悩開放－　レッツゴー！陰陽師　PV", 100]]
  end

  private
  def reset_db
    DB[:playlists].delete
    DB[:finishlists].delete
  end

  def db
    @db ||= DataBase.new
  end
end
