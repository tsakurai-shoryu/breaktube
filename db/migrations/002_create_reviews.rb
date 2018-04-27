
Sequel.migration do
  up do
    create_table :reviews do
      primary_key :id
      Integer :playlist_id, null: false
      String :user_name, null: false
      String :youtube_id, null: false
      Integer :vote, null: false
      Integer :created_at, null: false
    end
  end

  down do
    drop_table(:reviews)
  end
end