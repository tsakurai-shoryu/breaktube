Sequel.migration do
  up do
    create_table :playlists do
      primary_key :id
      String :user_name, null: false
      String :youtube_id, null: false
      Integer :created_at, null: false
    end
  end

  down do
    drop_table(:playlists)
  end
end

