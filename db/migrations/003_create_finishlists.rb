
Sequel.migration do
  up do
    create_table :finishlists do
      primary_key :id
      String :youtube_id, null: false
    end
  end

  down do
    drop_table(:finishlists)
  end
end