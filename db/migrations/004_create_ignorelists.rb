
Sequel.migration do
  up do
    create_table :ignorelists do
      primary_key :id
      String :youtube_id, null: false
    end
  end

  down do
    drop_table(:ignorelists)
  end
end