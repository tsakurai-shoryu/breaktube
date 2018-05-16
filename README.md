# breaktube

みんなで好きな曲を自由に共有するスラッシュコマンド。

sqlite3でbreaktube-prod.dbを作成し、テーブルを作る必要あり。
#breaktube-logを作る必要あり。

```
CREATE TABLE playlists(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    user_name TEXT NOT NULL,
      youtube_id TEXT NOT NULL,
        title_name TEXT NOT NULL,
          playback_time INTEGER NOT NULL,
            created_at INT NOT NULL
              );

CREATE TABLE reviews(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    playlist_id INT NOT NULL,
      user_name TEXT NOT NULL,
        youtube_id TEXT NOT NULL,
          vote INT NOT NULL,
            created_at INT NOT NULL
              );
```
